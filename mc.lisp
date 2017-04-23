(defun rand (x)
  (let ((x random-init))
    (lambda ()
      (set! x (rand-update x))
      x)))

;(defun gcd (x y)
;  (- x y))

(setf RANDOM-INIT 10)
(rand 455)

(defun estimate-pi (trials)
  (sqrt (/ 6 (monte-carlo trials cesaro-test))))
(defun cesaro-test
   (= (gcd (rand 100) (rand 49)) 1))
(defun monte-carlo (trials experiment)
  (defun iter (trials-remaining trials-passed)
    (cond ((= trials-remaining 0)
           (/ trials-passed trials))
          ((experiment)
           (iter (- trials-remaining 1) (+ trials-passed 1)))
          (else
           (iter (- trials-remaining 1) trials-passed))))
  (iter trials 0))


