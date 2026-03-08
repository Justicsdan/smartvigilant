from stable_baselines3 import PPO
import torch
import gym

env = gym.make("CartPole-v1")
model = PPO("MlpPolicy", env, verbose=0)
model.learn(total_timesteps=30000)

# Export red team policy to ONNX
dummy_input = torch.randn(1, env.observation_space.shape[0])

torch.onnx.export(
    model.policy,
    dummy_input,
    "../../../models/cyber/smart_redteam.onnx",
    opset_version=17,
    input_names=['obs'],
    output_names=['action']
)

print("✅ smart_redteam.onnx (automated red team simulator) successfully saved!")
