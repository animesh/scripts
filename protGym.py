#https://openai.com/blog/procgen-benchmark/
! pip install procgen --user
#$ python -m procgen.interactive --env-name starpilot # human
import gym
env = gym.make('procgen:procgen-coinrun-v0')
obs = env.reset()
while True:
    obs, rew, done, info = env.step(env.action_space.sample())
    env.render()
    if done:
        break
#https://openai.com/blog/safety-gym/
#https://github.com/openai/safety-gym
import safety_gym
import gym
env = gym.make('Safexp-PointGoal1-v0')
next_observation, reward, done, info = env.step(action)
info
#https://github.com/openai/safety-starter-agents


#https://openai.com/blog/deep-double-descent/
