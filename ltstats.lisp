;; -*- mode: common-lisp -*-
;;
;; Copyright (C) 2022,2023  Victor C. Salas P.
;;
;; Author: Victor C. Salas P. <nmagko@gmail.com>

;; LIGHTWEIGHT STATISTICS

(in-package "CLMATH")
;; (load (merge-pathnames "gnuplot.lisp" *load-truename*))

;; -- MEAN --
;; (float (/ (+ 8 12 11 15 12 2 16 3 6 19) 10))
;; 10.4f0
(declaim (ftype (function (CONS &optional FIXNUM) RATIO) mean))

(defun mean (L &optional A)
  "Average of a list of values"
  (declare (optimize (speed 3) (safety 0)))
  (setq A 0)
  (loop for n in L do
	(setq A (+ A n)))
  (/ A (list-length L)))

;; (float (mean (list 8 12 11 15 12 2 16 3 6 19)))
;; 10.4f0

;; -- MEDIAN --
;; (sort (list 8 12 11 15 12 2 16 3 6 19) #'<)
;; (2 3 6 8 11 12 12 15 16 19)
;; (float (/ (+ 11 12) 2))
;; 11.5f0
(declaim (ftype (function (CONS &optional CONS FIXNUM FIXNUM) RATIO) medn))

(defun medn (L &optional O S M)
  "Median of a list of values"
  (declare (optimize (speed 3) (safety 0)))
  (setq O (copy-list L))
  (setq O (sort O #'<))
  (setq S (list-length O))
  (setq M (floor (/ S 2)))
  (if (= (mod S 2) 0)
      (/ (+ (nth (- M 1) O) (nth M O)) 2)
      (nth M O)))

;; (float (medn (list 8 12 11 15 12 2 16 3 6 19)))
;; 11.5f0

;; -- MODE --
;; The mode is the most frequent score in our data set
(declaim (ftype (function (CONS &optional CONS FIXNUM FIXNUM FIXNUM CONS) CONS) mode))

(defun mode (L &optional O A C E P)
  "Mode of a list of values"
  (declare (optimize (speed 3) (safety 0)))
  (setq O (copy-list L))
  (setq O (sort O #'<))
  (setq A 0)
  (setq C 0)
  (setq E 0)
  (setq P nil)
  (loop for n in O do
	(if (= A n)
	    (setq C (+ C 1))
	    (progn
	      (if (> C E) (setq E C))
	      (setq C 0)
	      (setq A n))))
  (if (> E 0)
      (loop for n in O do
	    (if (= A n)
		(setq C (+ C 1))
		(progn
		  (if (= C E) (setq P (append P (list A))))
		  (setq C 0)
		  (setq A n))))) P)

;; (mode (list 8 12 11 6 15 12 2 16 3 6 19))
;; (6 12)

;; -- VARIANCE --
;;  1   n        _
;; ---  ∑  (Xᵢ - X)²
;; n-1 i=1
;; if the mean is the size of the population then
;; 1  N        
;; -  ∑  (Xᵢ - μ)²
;; N i=1
;; (/ (+ (expt (- 8 10.4) 2) (expt (- 12 10.4) 2) (expt (- 11 10.4) 2)
;;       (expt (- 15 10.4) 2) (expt (- 12 10.4) 2) (expt (- 2 10.4) 2)
;;       (expt (- 16 10.4) 2) (expt (- 3 10.4) 2) (expt (- 6 10.4) 2)
;;       (expt (- 19 10.4) 2)) 10)
;; 28.24
(declaim (ftype (function (CONS &optional FIXNUM FIXNUM) RATIO) varn))

(defun varn (L &optional M V)
  "Variance of a list of values"
  (declare (optimize (speed 3) (safety 0)))
  (setq M (mean L))
  (setq V 0)
  (loop for n in L do
	(setq V (+ V (expt (- n M) 2))))
  (if (= (round M) (list-length L))
      (/ V (list-length L))
      (/ V (- (list-length L) 1))))

;; (float (varn (list 8 12 11 15 12 2 16 3 6 19)))
;; 28.24f0

;; -- STANDARD DEVIATION --
;;    __________________
;;   /  1   n        _
;;  /  ---  ∑  (Xᵢ - X)²
;; √   n-1 i=1
;; if the mean is the size of the population then
;;    ________________
;;   / 1  N        
;;  /  -  ∑  (Xᵢ - μ)²
;; √   N i=1
;; (sqrt 28.24)
;; 5.314132102234569
(declaim (ftype (function (CONS) FLOAT) stde))

(defun stde (L)
  "Standard deviation of a list of values"
  (declare (optimize (speed 3) (safety 0)))
  (sqrt (varn L)))

;; (stde (list 8 12 11 15 12 2 16 3 6 19))
;; 5.314132f0

;; -- COEFFICIENT OF VARIATION --
;;         _
;; CV = S (X)⁻¹
;; if the coefficient of variation is for the population, then
;; CV = σ μ⁻¹
;; (/ 5.314132102234569 10.4)
;; 0.5109742405994778
(declaim (ftype (function (CONS) FLOAT) cova))

(defun cova (L)
  "Coefficient of variation of a list of values"
  (declare (optimize (speed 3) (safety 0)))
  (/ (stde L) (mean L)))

;; (cova (list 8 12 11 15 12 2 16 3 6 19))
;; 0.5109743f0

;; -- CORRELATION COEFFICIENT --
;;                _       _
;;        ₙ (aᵢ - A)(bᵢ - B)
;; rᴀ,ᴃ = ∑ ----------------
;;       ⁱ⁼¹ (n - 1) σᴀ σᴃ
;; rᴀ,ᴃ > 0 then A and B are positively correlated
;; rᴀ,ᴃ = 0 then A and B are independent
;; rᴀ,ᴃ < 0 then A and B are negatively correlated
;; r is dimensionless or lacking of units
(declaim (ftype (function (CONS CONS &optional FIXNUM FIXNUM FIXNUM FIXNUM FIXNUM) FLOAT) coco))

(defun coco (L1 L2 &optional A B D1 D2 S)
  "Correlation coefficient of two lists"
  (declare (optimize (speed 3) (safety 0)))
  (setq A (mean L1))
  (setq B (mean L2))
  (setq D1 (stde L1))
  (setq D2 (stde L2))
  (setq S 0)
  (do
   ((i 0 (+ i 1)))
   ((= i (list-length L1)) S)
    (setq S (+ S (/ (* (- (nth i L1) A) (- (nth i L2) B))
		    (* (- (list-length L1) 1) D1 D2))))))

;; (coco (list 32 45 39 43 58 84 65) (list 17 20 23 7 24 49 38))
;; 0.8775526f0

;; -- RANDOM NUMBERS --
;; Generate a collection filled with N normally distributed random numbers
;; with a mean M and a standard deviation D
(declaim (ftype (function (FIXNUM FIXNUM FIXNUM) CONS) rndn))

(defun rndn (M D N)
  "Normally distributed random numbers"
  (declare (optimize (speed 3) (safety 0)))
  (loop for i from 1 to N
	collect (+ M (* (sqrt (* -2 (log (random 1.0))))
			(cos (* 2 pi (random 1.0))) D))))

;; Generate a list with 250 values, where the values will concentrate
;; around 170, and the standard deviation is 10
;; (rndn 170 10 250)

;; -- HISTOGRAM --
;; The hist function draws an histogram from a list of values.
;; (defvar ll (list 08 13 15 10 16
;;                  11 14 11 14 20
;;                  15 16 12 15 13
;;                  12 13 16 17 17
;;                  14 14 14 18 15))
;; (hist ll 3)
(declaim (ftype (function (CONS &optional FIXNUM FIXNUM FIXNUM CONS FIXNUM FIXNUM CONS CONS) FIXNUM) hist))

(defun hist (L &optional (B 0) (MIN nil) (MAX nil) S M A X Y)
  (declare (optimize (speed 3) (safety 0)))
  (setq S (copy-list L))
  (setq S (sort S #'<))
  (if (not MIN) (setq MIN (floor (nth 0 S))))
  (if (not MAX) (setq MAX (ceiling (nth (1- (list-length S)) S))))
  (if (= B 0)
      (progn
	(setq B (ceiling (stde L)))
	(if (< (/ (- MAX MIN) B) 6)
	    (if (= B 1) (setq B (/ B 2))
		(setq B (ceiling B 2))))))
  (print (format t "~{~a~^ ~}" (list MIN MAX B)))
  (setq X (list MIN))
  (setq Y '())
  (setq M 0)
  (setq A (+ MIN B))
  (loop for i in S do
	(if (>= i A)
	    (progn
	      (setq X (append X (list A)))
	      (setq Y (append Y (list M)))
	      (do ((k (+ A B) (+ k B)))
		  ((< i k) (setq M 1) (setq A k))
		(setq X (append X (list k)))
		(setq Y (append Y (list 0)))))
	    (setq M (1+ M))))
  (setq Y (append Y (list M)))
  (gnuplot X Y (gppal 0 (format nil "boxes title \"~a Obs\"" (length L)))
	   (format
	    nil "~{~a~^~}"
	    (list "set boxwidth " (* B 1.0) ";"
		  "set style fill solid 1.0 border -1;"
		  "set xrange [" (* (- MIN B) 1.0) ":" (* (+ MAX B) 1.0) "];"
		  "set yrange [0.0:]"))))

;; (setq ll (list 1.45	2.20	0.75	1.23	1.25
;; 	       1.25	3.09	1.99	2.00	0.78
;; 	       1.32	2.25	3.15	3.85	0.52
;; 	       0.99	1.38	1.75	1.22	1.75))
;; (hist ll)
