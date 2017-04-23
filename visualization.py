"""
Functions to visualize a network built in NEST.
"""

import pydot
import nest

def plot_network(nodes, filename, ext_conns = False):
    """
    Plot the given nodes and the connections that originate from
    them. Note that connections to targets not in nodea are not drawn
    if ext_conns is False. If it is True, they are drawn to a node
    named 'ext'.
    """

    adjlist = [[j, nest.GetStatus(nest.FindConnections([j]), 'target')] for j in nodes]
    gr = pydot.Dot()
    
    for n in nodes:
        gr.add_node(pydot.Node(name=str(n)))
    
    for cl in adjlist:
        if not ext_conns:
            cl[1] = [i for i in cl[1] if i in nodes]
        else:
            tmp = []
            for i in cl[1]:
                if i in nodes: tmp.append(i)
                else: tmp.append("external")
            cl[1] = tmp
        for t in cl[1]:
            gr.add_edge(pydot.Edge(str(cl[0]), str(t)))
    
    gr.write_pdf(filename)
