"""Functions to refine a selection to varying degrees. These functions are 
   usually used by setting the md_level member of an automodel or loop model
   object."""


def very_fast(atmsel, actions):
    """Very fast MD annealing"""
    # at T=1000, max_atom_shift for 4fs is cca 0.15 A.
    refine(atmsel, actions, cap=0.39, timestep=4.0,
           equil_its=50, equil_equil=10,
           equil_temps=(150.0, 400.0, 1000.0),
           sampl_its=300, sampl_equil=100,
           sampl_temps=(1000.0, 800.0, 500.0, 300.0))


def fast(atmsel, actions):
    """Fast MD annealing"""
    refine(atmsel, actions, cap=0.39, timestep=4.0,
           equil_its=100, equil_equil=20,
           equil_temps=(150.0, 250.0, 500.0, 1000.0),
           sampl_its=400, sampl_equil=100,
           sampl_temps=(1000.0, 800.0, 500.0, 300.0))


def slow(atmsel, actions):
    """Slow MD annealing"""
    refine(atmsel, actions, cap=0.39, timestep=4.0,
           equil_its=200, equil_equil=20,
           equil_temps=(150.0, 250.0, 400.0, 700.0, 1000.0),
           sampl_its=600, sampl_equil=200,
           sampl_temps=(1000.0, 800.0, 600.0, 500.0, 400.0, 300.0))


def very_slow(atmsel, actions):
    """Very slow MD annealing"""
    refine(atmsel, actions, cap=0.39, timestep=4.0,
           equil_its=300, equil_equil=20,
           equil_temps=(150.0, 250.0, 400.0, 700.0, 1000.0, 1300.0),
           sampl_its=1000, sampl_equil=200,
           sampl_temps=(1300.0, 1000.0, 800.0, 600.0, 500.0, 430.0, 370.0,
                        320.0, 300.0))


def slow_large(atmsel, actions):
    """Very slow/large dt MD annealing"""
    refine(atmsel, actions, cap=0.39, timestep=10.0,
           equil_its=200, equil_equil=20,
           equil_temps=(150.0, 250.0, 400.0, 700.0, 1000.0, 1500.0),
           sampl_its=2000, sampl_equil=200,
           sampl_temps=(1500.0, 1000.0, 800.0, 600.0, 500.0, 400.0, 300.0))


def refine(atmsel, actions, cap, timestep, equil_its, equil_equil,
           equil_temps, sampl_its, sampl_equil, sampl_temps, **args):
    from modeller.optimizers import molecular_dynamics

    mdl = atmsel.get_model()
    md = molecular_dynamics(cap_atom_shift=cap, md_time_step=timestep,
                            md_return='FINAL', output=mdl.optimize_output,
                            actions=actions, **args)
    init_vel = True
    # First run for equilibration, the second for sampling:
    for (its, equil, temps) in ((equil_its, equil_equil, equil_temps),
                                (sampl_its, sampl_equil, sampl_temps)):
        for temp in temps:
            md.optimize(atmsel, max_iterations=its, equilibrate=equil,
                        temperature=temp, init_velocities=init_vel)
            init_vel=False
