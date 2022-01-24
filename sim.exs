#https://medium.com/pragmatic-programmers/using-genetic-algorithms-to-simulate-evolutio-n-946eefd95cd2
​ ​defmodule​ TigerSimulation ​do​
​   @behaviour Problem
​   alias Types.Chromosome
​ 
​   @impl true
​   ​def​ genotype, ​do​: ​# ...​
​ 
​   @impl true
​   ​def​ fitness_function(c), ​do​: ​# ...​
​ 
​   @impl true
​   ​def​ terminate?(population, generation), ​do​: ​# ...​
​ ​end​

+--------------------+--------------+--------------+
|                    |  0           |  1           |
+--------------------+--------------+--------------+
|  Size              |  smaller     |  larger      |
|  Swimming Ability  |  low         |  high        |
|  Fat Stores        |  less        |  more        |
|  Activity Period   |  diurnal     |  nocturnal   |
|  Hunting Range     |  smaller     |  larger      |
|  Fur Thickness     |  less thick  |  more thick  |
|  Tail Length       |  smaller     |  larger      |
+--------------------+--------------+--------------+

​ ​def​ genotype ​do​
​   genes = for _ <- 1..8, ​do​: Enum.random(0..1)
​   %Chromosome{​genes:​ genes, ​size:​ 8}
​ ​end​

+--------------------+------------+----------+
|  Trait             |  Tropical  |  Tundra  |
+--------------------+------------+----------+
|  Size              |    0.0     |   1.0    |
|  Swimming Ability  |    3.0     |   3.0    |
|  Fur Color         |    2.0     |  -2.0    |
|  Fat Stores        |  -1.0      |   1.0    |
|  Activity Period   |    0.5     |   0.5    |
|  Hunting Ground    |    1.0     |   2.0    |
|  Fur Thickness     |  -1.0      |   1.0    |
|  Tail Length       |    0.0     |   0.0    |
+--------------------+------------+----------+

​ ​def​ fitness_function(chromosome) ​do​
​   tropic_scores = [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
​   tundra_scores = [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]
​   traits = chromosome.genes
​ 
​   traits
​   |> Enum.zip(tropic_scores)
​   |> Enum.map(​fn​ {t, s} -> t*s ​end​)
​   |> Enum.sum()
​ ​end​

 ​def​ terminate?(_population, generation), ​do​: generation == 1000

 ​ sim = Genetic.run(sim,
​                     ​population_size:​ 20,
​                     ​selection_rate:​ 0.9,
​                     ​mutation_rate:​ 0.1)
​ 
​ IO.write(​"​​\n"​)
​ IO.inspect(tiger)

👈 Chapter 9 Tracking Genetic Algorithms | TOC | Logging Statistics Using ETS 👉
One of the more interesting applications of genetic algorithms that you have yet to discover is their ability to model real evolutionary processes. Genetic algorithms are inspired by evolution, and while the internal processes that guide genetic algorithms such as selection, crossover, and mutation are only loosely based on science, they can still be used to offer valuable insights into the evolutionary process.
Say you’ve been tasked by a biologist to write a simulation of how tigers evolve under different environmental conditions. Obviously, the traits required to survive in a desert versus an arctic tundra differ drastically. Your goal is to write a simulation that models the basic evolution of the tiger in two different environments, tropical and tundra, over the course of 1000 generations. Additionally, your simulation needs to keep track of valuable statistics such as average fitness, average age, genealogy, and the most fit chromosome from every generation.
Using a genetic algorithm and a bit of knowledge about tigers, you can accomplish this task in no time.
Start by creating a new file in scripts named tiger_simulation.exs. Next, create a shell for a Problem in tiger_simulation.exs, like so:
​ ​defmodule​ TigerSimulation ​do​
​   @behaviour Problem
​   alias Types.Chromosome
​ 
​   @impl true
​   ​def​ genotype, ​do​: ​# ...​
​ 
​   @impl true
​   ​def​ fitness_function(c), ​do​: ​# ...​
​ 
​   @impl true
​   ​def​ terminate?(population, generation), ​do​: ​# ...​
​ ​end​
By now, all of this code should be familiar. Now you need to figure out how to fit your simulation into the Problem behaviour.
Representing Tigers as Chromosomes
The first thing you need to do is determine how to represent tigers as chromosomes.
While there’s no right or wrong answer, the easiest way is to use a binary genotype that represents various traits present in a single tiger. Each of these traits contributes in one way or another to the tiger’s ability to survive in different environments.
You’ll monitor eight traits as shown in the table.
+--------------------+--------------+--------------+
|                    |  0           |  1           |
+--------------------+--------------+--------------+
|  Size              |  smaller     |  larger      |
|  Swimming Ability  |  low         |  high        |
|  Fat Stores        |  less        |  more        |
|  Activity Period   |  diurnal     |  nocturnal   |
|  Hunting Range     |  smaller     |  larger      |
|  Fur Thickness     |  less thick  |  more thick  |
|  Tail Length       |  smaller     |  larger      |
+--------------------+--------------+--------------+
Because you’re monitoring eight traits, your chromosome will consist of eight binary genes. Implement the genotype like this:
​ ​def​ genotype ​do​
​   genes = for _ <- 1..8, ​do​: Enum.random(0..1)
​   %Chromosome{​genes:​ genes, ​size:​ 8}
​ ​end​
As you’ve seen before, this is a basic binary genotype of size 8. The initial population will contain tigers of varying combinations of traits.
The next thing you need to do is determine how to evaluate each tiger based on its traits in both a tropical and tundra environment.
Evaluating Fitness in Different Environments
Remember, your goal is to determine how tigers evolve in each environment. Because the importance of each trait differs between environments, you need to evaluate chromosomes differently depending on the environment.
The easiest way to do this is to assign weights or scores to each trait, indicating whether or not a trait is positive or negative to survival. The magnitude of a weight or score indicates the relative importance of that trait in a given environment.
The table shows the scores you’ll assign to each trait in both environments.
+--------------------+------------+----------+
|  Trait             |  Tropical  |  Tundra  |
+--------------------+------------+----------+
|  Size              |    0.0     |   1.0    |
|  Swimming Ability  |    3.0     |   3.0    |
|  Fur Color         |    2.0     |  -2.0    |
|  Fat Stores        |  -1.0      |   1.0    |
|  Activity Period   |    0.5     |   0.5    |
|  Hunting Ground    |    1.0     |   2.0    |
|  Fur Thickness     |  -1.0      |   1.0    |
|  Tail Length       |    0.0     |   0.0    |
+--------------------+------------+----------+
Determining Scores
INFORMATION
images/aside-icons/info.png
The scores chosen for each trait in this example are arbitrary. In a practical simulation, you’d want to determine scores with research and data, and hopefully be able to provide a justification for each one. These scores were chosen based on intuition. They don’t mean anything nor are they scientifically correct. You can always adjust them and see how it affects your evolutions.
Notice that some scores are negative, indicating that they have a negative impact on survival; some scores are zero, indicating they have no impact on survival; and some are positive, indicating they have a positive impact on survival.
Now, to translate these scores into a fitness function, add the following code to tiger_simulation.exs:
​ ​def​ fitness_function(chromosome) ​do​
​   tropic_scores = [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
​   tundra_scores = [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]
​   traits = chromosome.genes
​ 
​   traits
​   |> Enum.zip(tropic_scores)
​   |> Enum.map(​fn​ {t, s} -> t*s ​end​)
​   |> Enum.sum()
​ ​end​
The fitness function pairs traits with their corresponding score, multiplies them together, and returns the sum to represent a tiger’s ability to survive in the given environment. For simplicity, you can just change tropic_scores with tundra_scores in Enum.map/2 when running trials on different environments. In practice, you’d want a way to change this dynamically and run experiments side by side.
Finishing and Running the Simulation
All that’s left for you to do is define some termination criteria. You’ll want to stop the evolution after 1000 generations. Implement your termination criteria like this:
​ ​def​ terminate?(_population, generation), ​do​: generation == 1000
Next, add the following below the TigerSimulation module:
​ tiger = Genetic.run(TigerSimulation,
​                     ​population_size:​ 20,
​                     ​selection_rate:​ 0.9,
​                     ​mutation_rate:​ 0.1)
​ 
​ IO.write(​"​​\n"​)
​ IO.inspect(tiger)
You pass your TigerSimulation into Genetic.run/2 as well as specify a population size of 20, selection rate of 0.9 and a mutation rate of 0.9.
Remember, Genetic.run/2 returns the best chromosome in the population after the termination criteria has been met. That means that tiger will be the current best chromosome in the population after 1000 generations.
Now, run your genetic algorithm in a tropic environment (with tropic_scores):
​ ​$ ​​mix​​ ​​run​​ ​​scripts/tiger_simulation.exs​
​ Current best: 7.5000  Generation: 1000
​ %Types.Chromosome{
​   age: 1,
​   fitness: 7.5,
​   genes: [0, 1, 1, 1, 1, 1, 0, 1],
​   size: 8
​ }
And again in a tundra environment (with tundra_scores):
​ ​$ ​​mix​​ ​​run​​ ​​scripts/tiger_simulation.exs​
​ Current best: 7.5000  Generation: 1000
​ %Types.Chromosome{
​   age: 1,
​   fitness: 7.5,
​   genes: [1, 1, 0, 0, 1, 1, 1, 0],
​   size: 8
​ }
You’ve successfully analyzed and produced the fittest tiger in each environment. You can see that in tropical environments, the best tiger is smaller, a strong swimmer, and has dark fur and a generally smaller hunting territory. The tundra tiger is larger, a strong swimmer, and has lighter fur and larger fat stores.
You might be thinking that achieving this result isn’t that impressive. You could have derived them yourself intuitively or through a simple brute-force search. However, the most important aspect of this experiment isn’t the final result but what happens before that. You need a way to peek inside.
👈 Chapter 9 Tracking Genetic Algorithms | TOC | Logging Statistics Using ETS 👉
Genetic Algorithms in Elixir by Sean Moriarity can be purchased in other book formats directly from the Pragmatic Programmers. If you notice a code error or formatting mistake, please let us know here so that we can fix it.

The Pragmatic Programmers
We create timely, practical books and learning resources on classic and cutting-edge topics to help you practice your craft and accelerate your career.

Follow

6


Sign up for Pragmatic Voices
By The Pragmatic Programmers
A monthly summary of what's happening on Medium with The Pragmatic Programmers Take a look.

Your email

Get this newsletter
By signing up, you will create a Medium account if you don’t already have one. Review our Privacy Policy for more information about our privacy practices.

Smgaelixir
6







More from The Pragmatic Programmers

Follow
We create timely, practical books and learning resources on classic and cutting-edge topics to help you practice your craft and accelerate your career.

Read more from The Pragmatic Programmers
More From Medium
Tracking Genealogy in a Genealogy Tree
The Pragmatic Programmers in The Pragmatic Programmers

NBA Data Visualuzation in Python
Joe Leuschen

Is your data ready for AI?
Bryan Smith in Namara

A GIS based machine learning algorithm to predict price of Airbnb’s hotel rooms in Newyork city…
Himanshu Bhardwaj

Day (4) — Data Visualization — How to use Seaborn for Heatmaps
Keith Brooks

Mean and median, main differences and how to calculate them
Hard way to Data Science

Business Analytics tools, benefits & use cases | Apiumhub
Apiumhub

Python Top 10 Open Source Projects (v.Mar 2018)
Mybridge in Mybridge for Professionals

About

Write

Help

Legal
