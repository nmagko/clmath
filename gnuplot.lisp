;; -*- mode: common-lisp -*-
;;
;; Copyright (C) 2022,2023  Victor C. Salas P.
;;
;; Author: Victor C. Salas P. <nmagko@gmail.com>

;; COMMON LISP GNUPLOT INTERFACE

(in-package "CLMATH")
;; (require :uiop)

;; It runs the gnuplot program in the background via the uiop interface.
;; Self-documented in the comments with examples.

;; system variables
(defvar *gnuplot-cache-path* "/dev/shm")
(defvar *gnuplot-cache-name* "")
(defvar *gnuplot-cache-stat* nil)
(defvar *gnuplot-cache-show* "")

;; The range function creates a list of integers from min to max by a
;; defined step (default 1).
(defun range (MI MA &optional (ST 1))
  (declare (optimize (speed 3) (safety 0)))
  (loop for n from MI below (+ MA ST) by ST collect n))

;; The linspace function return evenly spaced numbers over a specified
;; interval. It divides evenly spaced DV samples, calculated over the
;; interval [MI, MA].
(defun linspace (MI MA &optional (DV 50))
  (declare (type (unsigned-byte *) DV))
  (if (= DV 0) ()
      (if (= DV 1) (list MI)
	  (range MI MA (/ (- MA MI) (- DV 1))))
      ))

;; The gppal function returns gnuplot format color added to type
;; Defaults: blue boxes
;; Colors: blue, green, purple, orange, yellow, brown, pink, red,
;;         blue gray, green gray
(defun gppal (&optional (I 0) (S "boxes") C)
  (declare (optimize (speed 3) (safety 0)))
  (setq C '("#377EB8" "#4DAF4A" "#984EA3" "#FF7F00" "#EFEF00"
	    "#A65628" "#F781BF" "#E83034" "#666699" "#669999"))
  (format nil "~a lc rgb \"~a\"" S (nth (mod I (list-length C)) C)))

;; The Gnuplot function plots the x-axis and y-axis lists with a defined
;; plot type (default boxes). You can improve your output with an
;; additional script that has to be written in Gnuplot format to set
;; parameters like boxwidth, style, xrange, yrange, etc., and it's
;; evaluated before your data is plotted. E.g. Percentage of savings per
;; quarter.
;; * (gnuplot '(1 2 3 4) '(0.34 0.70 0.60 0.50) "boxes"
;;    "set boxwidth 0.8;set style fill solid 1.0;set yrange [0.0:0.8];")
;; You can extend functionality by adding a fifth argument as a string that
;; have x-limit range to be filled. It's mostly used with plotfn extended
;; function. E.g. "1,2" means to limit x range from 1 to 2.
(defun gnuplot (X Y &optional (TYPE "boxes") (SCRIPT "") (LIMIT ""))
  (declare (optimize (speed 3) (safety 0)))
  (setq *gnuplot-cache-name*
	(concatenate 'string *gnuplot-cache-path* "/gnuplot-" (write-to-string (+ 1000 (random 9000))) ".dat"))
  (let ((s (open *gnuplot-cache-name* :direction :output
                 :if-exists :supersede :if-does-not-exist :create)))
    (do ((i 0 (+ i 1)))
	((= i (list-length X)) t)
      (write-line (format nil "~f ~f" (nth i X) (nth i Y)) s))
    (close s))
  (uiop:run-program
   (format
    nil "~a~{~a~^ ~}"
    "gnuplot -p -e '"
    (list
     SCRIPT ";"
     (if (string= LIMIT "")
	 "" "gpllrf(x,x0,x1)=(x0<=x&&x<=x1)?x:NaN;")
     "plot" (concatenate 'string "\"" *gnuplot-cache-name* "\"") "using"
     (if (string= LIMIT "")
	 "1:2" (concatenate 'string "(gpllrf($1," LIMIT ")):2"))
     "with" TYPE
     ;; (if (string= LIMIT "")
     ;; 	 "" "notitle, \"\" using 1:2 with lines")
     ;; "notitle'"
     "'"
     ))
   ))

;; The setplot function works exactly like the gnuplot function but don't
;; show any plot. You have to call the showplots function to show the plots.
;; With the setplot function you can stack multiple plots to be shown later
;; with showplots.
(defun setplot (X Y &optional (TYPE "boxes") (SCRIPT "") (LIMIT ""))
  (declare (optimize (speed 3) (safety 0)))
  (setq *gnuplot-cache-name*
	(concatenate 'string *gnuplot-cache-path* "/gnuplot-" (write-to-string (+ 1000 (random 9000))) ".dat"))
  (let ((s (open *gnuplot-cache-name* :direction :output
                 :if-exists :supersede :if-does-not-exist :create)))
    (do ((i 0 (+ i 1)))
	((= i (list-length X)) t)
      (write-line (format nil "~f ~f" (nth i X) (nth i Y)) s))
    (close s))
  (if (not *gnuplot-cache-stat*)
      (setq *gnuplot-cache-show*
	    (concatenate 'string *gnuplot-cache-path* "/gnuplot-" (write-to-string (+ 1000 (random 9000))) ".plt")))
  (let ((s (open *gnuplot-cache-show* :direction :output
                 :if-exists :append :if-does-not-exist :create)))
    (write-line
     (format
      nil "~{~a~^ ~}"
      (list
       SCRIPT ";"
       (if (string= LIMIT "")
	   "" "gpllrf(x,x0,x1)=(x0<=x&&x<=x1)?x:NaN;")
       (if *gnuplot-cache-stat*
	   "replot" "plot")
       (concatenate 'string "\"" *gnuplot-cache-name* "\"") "using"
       (if (string= LIMIT "")
	   "1:2" (concatenate 'string "(gpllrf($1," LIMIT ")):2"))
       "with" TYPE
       ;; (if (string= LIMIT "")
       ;; 	   "" "notitle, \"\" using 1:2 with lines")
       ;; "notitle"
       ))
     s)
    (close s))
  (if (not *gnuplot-cache-stat*)
      (setq *gnuplot-cache-stat* t))
  )

;; The function showplots show the plots previously defined by setplot.
(defun showplots ()
  (if *gnuplot-cache-stat*
      (setq *gnuplot-cache-stat* nil))
  (uiop:run-program
   (format
    nil "~{~a~^ ~}"
    (list "gnuplot -p -c" *gnuplot-cache-show*))))

;; The plotfn function receives min, max, and function and then plots it by
;; using Gnuplot. E.g. Plot f(x) = log ( 1 + x ) from 0 to 10 with
;; increments of 1. Then it goes 0, 1, 2, 3, ... 9, 10
;; * (plotfn 0 10 #'(lambda (x) (log (+ 1 x))))
;; The fourth argument is optional argument and sets a divisor for the
;; increment. E.g. Set the fourth argument with 10 as a divisor.
;; * (plotfn 0 10 #'(lambda (x) (log (+ 1 x))) 10)
;; Then it goes 0.0, 0.1, 0.2, 0.3, ..., 9.9, 10.0
;; You can extend functionality with additional arguments like plot type,
;; script, and limit x range.
;; * (plotfn 0 5 #'(lambda (x) (e (- x))) 10 "filledcurve y1=0" "" "0,2")
(defun plotfn (MI MA FN &optional (DV 1) (TYPE "lines")
			  (SCRIPT "") (LIMIT "") (X '()) (Y '()))
  (declare (optimize (speed 3) (safety 0)))
  (loop for i in (range (* MI DV) (* MA DV))
	do (setq X (append X (list (/ i DV)))))
  (loop for i in (mapcar FN X)
	do (setq Y (append Y (list i))))
  (gnuplot X Y (gppal 0 TYPE) SCRIPT LIMIT))
