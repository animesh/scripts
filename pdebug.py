import pdb
def combine(s1,s2):      # define subroutine combine, which...
    s3 = s1 + s2 + s1    # sandwiches s2 between copies of s1, ...
    s3 = '"' + s3 +'"'   # encloses it in double quotes,...
    return s3            # and returns it.
    
a = "aaa"
pdb.set_trace()
b = "bbb"
c = "ccc"
final = combine(a,b)
print final


my_list = [12, 5, 13, 8, 9, 65]
def bubble(bad_list):
    length = len(bad_list) - 1
    sorted = False

    while not sorted:
        sorted = True
        for i in range(length):
            if bad_list[i] > bad_list[i+1]:
                sorted = False
                bad_list[i], bad_list[i+1] = bad_list[i+1], bad_list[i]

bubble(my_list)
print my_list

"""
http://stackoverflow.com/questions/895371/bubble-sort-homework
n <enter>
<enter>
p <variable>
q
c
l
s
r
source http://pythonconquerstheuniverse.wordpress.com/category/python-debugger/
http://www.youtube.com/watch?v=bZZTeKPRSLQ 
"""
