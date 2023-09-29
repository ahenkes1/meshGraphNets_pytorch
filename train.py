"""Train."""
from dataset import FPC
from model.simulator import Simulator
import torch
from utils.noise import get_velocity_noise
from utils.utils import NodeType
from torch_geometric.loader import DataLoader
import torch_geometric.transforms as T

dataset_dir = "dataset/cylinder_flow/h5/"
batch_size = 8
noise_std = 2e-2
epochs = 1

print_batch = 1
save_batch = 200


device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
simulator = Simulator(
    message_passing_num=15,
    node_input_size=11,
    edge_input_size=3,
    device=device,
)
optimizer = torch.optim.AdamW(simulator.parameters(), lr=3e-5)
print("Optimizer initialized")


def train(model: Simulator, dataloader, optimizer):
    """Train."""
    for batch_index, graph in enumerate(dataloader):
        graph = transformer(graph)
        if torch.cuda.is_available():
            graph = graph.cuda()

        node_type = graph.x[:, 0]  # "node_type, cur_v, pressure, time"
        velocity_sequence_noise = get_velocity_noise(
            graph, noise_std=noise_std, device=device
        )
        predicted_acc, target_acc = model(graph, velocity_sequence_noise)
        mask = torch.logical_or(
            node_type == NodeType.NORMAL, node_type == NodeType.OUTFLOW
        )

        errors = ((predicted_acc - target_acc) ** 2)[mask]
        loss = torch.mean(errors)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        if batch_index % print_batch == 0:
            print("batch %d [loss %.2e]" % (batch_index, loss.item()))

        if batch_index % save_batch == 0:
            model.save_checkpoint()


if __name__ == "__main__":
    dataset_fpc = FPC(dataset_dir=dataset_dir, split="train", max_epochs=epochs)
    train_loader = DataLoader(
        dataset=dataset_fpc, batch_size=batch_size, num_workers=4
    )
    transformer = T.Compose(
        [T.FaceToEdge(), T.Cartesian(norm=False), T.Distance(norm=False)]
    )
    train(simulator, train_loader, optimizer)
