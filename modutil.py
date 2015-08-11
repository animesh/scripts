from modeller.util.logger import log

exclusions = {
    'model.write': ('write_all_atoms',),
    'model.generate_topology': ('iseq',),
    'selection.write': ('write_all_atoms',),
    'restraints.unpick': ('atom_ids',),
    'restraints.make_distance': ('restraint_type',)
}

def set_tops(logname, dictvars, defs, arg_allowed):
    args = []
    nolog = ['sel1', 'sel2', 'sel3']
    try:
        nolog.extend(exclusions[logname])
    except KeyError:
        pass
    logstring = "runcmd______> " + logname + '('
    first = True
    if not isinstance(arg_allowed, (tuple, list)):
        arg_allowed = (arg_allowed,)
    for key in arg_allowed:
        if key in dictvars:
            if key not in nolog:
                if not first:
                    logstring += ', '
                first = False
                logstring += key + "=" + repr(dictvars[key])
            a = dictvars[key]
            if hasattr(a, "modpt"):
                a = a.modpt
            args.append(a)
            del dictvars[key]
        else:
            try:
                defval = eval("defs."+key)
            except AttributeError:
                require_argument(key, logname)
            if key not in nolog:
                if not first:
                    logstring += ', '
                first = False
                logstring += "(def)" + key + "=" + repr(defval)
            if hasattr(defval, "modpt"):
                defval = defval.modpt
            args.append(defval)
    for key in dictvars:
        raise SyntaxError, "Variable " + repr(key) + \
                           " is not valid for " + logname
    if log.output:
        print logstring + ')'
    return args

def require_argument(key, logname):
    raise SyntaxError, "A value must be given for " + repr(key) + \
                       " for " + logname

def handle_seq_indx(seqtype, indx, lookup_func=None, lookup_args=(),
                    require_inrange=True):
    if isinstance(indx, int):
        if indx < 0:
            indx += len(seqtype)
        if indx < 0 or indx >= len(seqtype):
            if require_inrange:
                raise IndexError, "list index out of range"
            else:
                indx = max(indx, 0)
                indx = min(indx, len(seqtype))
                return indx
        else:
            return indx
    elif isinstance(indx, slice):
        return range(*indx.indices(len(seqtype)))
    elif lookup_func is not None:
        args = lookup_args + (indx,)
        int_indx = lookup_func(*args)
        if int_indx < 0:
            raise KeyError, indx
        else:
            return int_indx
    else:
        raise TypeError, "expecting an integer index"
