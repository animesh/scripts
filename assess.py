"""Functions to assess a model or selection. Each should take a selection
   object, and return a tuple containing the score name, and the score
   itself."""

def GA341(atmsel):
    """Returns the GA341 score of the given model."""
    mdl = atmsel.get_model()
    return ('GA341 score', mdl.assess_ga341())


def DOPE(atmsel):
    """Returns the DOPE score of the given model."""
    return ('DOPE score', atmsel.assess_dope())


def DOPEHR(atmsel):
    """Returns the DOPE-HR score of the given model."""
    return ('DOPE-HR score', atmsel.assess_dopehr())


def normalized_dope(atmsel):
    """Returns the normalized DOPE score of the given model."""
    mdl = atmsel.get_model()
    return ('Normalized DOPE score', mdl.assess_normalized_dope())
