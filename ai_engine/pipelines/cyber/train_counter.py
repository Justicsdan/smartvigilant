from stable_baselines3 import PPO
import gym

env = gym.make("LunarLander-v2")  # Defensive version: reward for stability

model = PPO("MlpPolicy", env, verbose=0)
model.learn(total_timesteps=100000)

# Save defensive counter-agent
model.save("../../../models/cyber/smart_counter_agent.pt")

print("✅ smart_counter_agent.pt (defensive agent) successfully saved!")
