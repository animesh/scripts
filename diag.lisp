;; (+ 1 1)
(load "/media/DATA/actr6/load-act-r-6.lisp")
;; load GUI ; cd /media/DATA/actr6/environment/GUI ; wish starter.tcl &
;; /usr/bin/wish /media/DATA/actr6/environment/GUI/starter.tcl &
(sb-ext:run-program "/usr/bin/wish" (list "/media/DATA/actr6/environment/GUI/starter.tcl"))
(start-environment)
(load "/media/DATA/actr6/tutorial/unit1/count.lisp")
(run 1)
(reset)
(stop-environment)
(load "/media/DATA/actr6/tutorial/unit2/demo2.lisp")
(do-demo2 'human)













