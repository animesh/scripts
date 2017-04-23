import util.top as top

def delete(file):
    """Delete a file"""
    return top.top().delete_file('modfile.delete', file=file)


def inquire(file):
    """Check if file exists"""
    return top.top().inquire('modfile.inquire', file=file)


def default(root_name='undf', file_id='X', id1=1, id2=1, file_ext=''):
    """Generate a default Modeller-style file name"""
    return "%s%s%04d%04d%s" % (root_name, file_id, id1, id2, file_ext)
