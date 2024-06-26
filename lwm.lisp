;; -*- mode: common-lisp -*-
;;
;; Copyright (C) 2022,2023  Victor C. Salas P.
;;
;; Author: Victor C. Salas P. <nmagko@gmail.com>

;; LINEAR ALGEBRA

(in-package "CLMATH")

;; Lightweight Matrices
;; It allows to you to use lists as arrays and viceversa.
;; It complements the matrix.lisp module of clmath.
;; Self-documented in the comments with examples.

;; Creates 1-column space list
(defun cspl (&rest L)
  "It creates 1-column space list"
  (let* ((V ()))
    (do ((i 0 (+ 1 i)))
	((>= i (length L)) V)
      (setq V (append V (list (list (nth i L))))))))

;; Converting a column space list to a 2D-array matrix
(defun cspl-to-mat (L)
  "It converts a column space list L to a 2D-array matrix"
  (make-array (list (length L) (length (nth 0 L)))
	      :initial-contents L))

;; Converting a 2D-array matrix to a column space list
(defun mat-to-cspl (M)
  "It converts a 2D-array matrix M to a column space list"
  (loop for i below (array-dimension M 0)
	collect (loop for j below (array-dimension M 1)
		      collect (aref M i j))))

;; Return a new matrix which is equal to 2D-array M
(defun copy-mat (M)
  "Return a new matrix which is equal to 2D-array M"
  (cspl-to-mat (mat-to-cspl M)))

;; List reference LREF
(defun lref (L I J)
  "Return the element of the L list specified by I J indexes"
  (nth J (nth I L)))

(defun (setf lref) (N L I J)
  (setf (nth J (nth I L)) N))

;; Transpose of a 2D-array matrix from column space list
(defun transpose-lmat (L &optional M)
  "Return the transpose of a 2D-array matrix from column space list L"
  (setq M (cspl-to-mat L))
  (loop for i below (array-dimension M 1)
	collect (loop for j below (array-dimension M 0)
		      collect (aref M j i))))

;; Transpose of a 2D-array matrix from 2D-array matrix
(defun transpose-amat (M)
  "Return the transpose of a 2D-array matrix from 2D-array matrix M"
  (cspl-to-mat
   (loop for i below (array-dimension M 1)
	 collect (loop for j below (array-dimension M 0)
		       collect (aref M j i)))))

;; EXAMPLE: XᵀY THE INNER PRODUCT OF VECTOR Xᵀ AND VECTOR Y

;; (defvar x (cspl-to-mat '((1) (0) (-1))))
;; (defvar y (cspl-to-mat '((3) (2) (0))))
;; (defvar z (clmath:matrix-multiply (transpose-amat x) y))

;; CORRELATION BETWEEN VECTORS

;; Norm tell us the length of a vector (ℓp-norm) and when a vector
;; is correlated to another
(defun lp-norm (M &optional (P 2) (X 0))
  "Return the length of a vector (defaults ℓ₂-norm)"
  (loop for i below (array-dimension M 0)
	do (loop for j below (array-dimension M 1)
		 do (setq X (+ X (expt (abs (aref M i j)) P)))))
  (expt X (/ 1 P)))

;; (lp-norm x)
;; (lp-norm y)

;; The cosine angle between two vectors x and y shows us the
;; correlation to but between -1 and 1
(defun cosang (X Y &optional Z)
  "Return the cosine angle between two vectors X and Y"
  (setq Z (clmath:matrix-multiply (transpose-amat X) Y))
  (clmath:matrix-multiply Z (/ 1 (* (lp-norm X) (lp-norm Y)))))

;; (cosang x y)

;; Given three example vectors down below, find if they are
;; correlated
;; +---------+---------+---------+
;; |      x1 |      x2 |      x3 |
;; +---------+---------+---------+
;; |  0.0006 | -0.0011 | -0.0020 |
;; | -0.0014 | -0.0024 | -0.0059 |
;; | -0.0034 |  0.0073 | -0.0099 |
;; |  0.0001 | -0.0066 | -0.0030 |
;; |  0.0074 |  0.0046 |  0.0116 |
;; |  0.0007 | -0.0061 | -0.0017 |
;; +---------+---------+---------+
;; (defvar x1 (cspl-to-mat
;; 	    (cspl  0.0006
;; 		  -0.0014
;; 		  -0.0034
;; 		   0.0001
;; 		   0.0074
;; 		   0.0007)
;; 	    ))
;; (defvar x2 (cspl-to-mat
;; 	    (cspl -0.0011
;; 		  -0.0024
;; 		   0.0073
;; 		  -0.0066
;; 		   0.0046
;; 		  -0.0061)
;; 	    ))
;; (defvar x3 (cspl-to-mat
;; 	    (cspl -0.0020
;; 		  -0.0059
;; 		  -0.0099
;; 		  -0.0030
;; 		   0.0116
;; 		  -0.0017)
;; 	    ))
;; (cosang x1 x2)
;; (cosang x1 x3)

;; Diagonal 2D-array matrix from a 1-column space list
(defun cspl-to-diagmat (L &optional V M N)
  "Given a 1-column space list, it returns a diagonal matrix"
  (setq V (cspl-to-mat L))
  (setq N (array-dimension V 0))
  (setq M (make-array (list N N) :initial-element 0))
  (do ((i 0 (+ 1 i)))
      ((>= i N) M)
    (setf (aref M i i)
	  (aref V i 0))))

;; Example: creating a diagonal 2D-array matrix
;; (cspl-to-diagmat '((1/100) (2/10) (3) (0.4)))
;; The same by using a column space list function
;; (cspl-to-diagmat (cspl 1/100 2/10 3 0.4))

;; (defvar w (cspl-to-mat '((1 2 3) (4 5 6) (7 8 9))))
;; (defvar x (cspl-to-mat (cspl 2 -1 1)))
;; (defvar z (clmath:matrix-multiply (transpose-amat x) (clmath:matrix-multiply w x)))

;; Example: Minimization problem by solving linear equation Xβ = y,
;; the solution is β = (Xᵀ X)⁻¹ Xy
;; (defvar x (cspl-to-mat '((1 3) (-2 7) (0 1))))
;; (defvar xtx (clmath:matrix-multiply (transpose-amat x) x))
;; (defvar xtxinv (copy-mat xtx))
;; ;; matrix-inverse is destructive, it overwrites the matrix given
;; (clmath:matrix-inverse xtxinv)
;; (defvar y (cspl-to-mat (cspl 2 1 0)))
;; (clmath:matrix-multiply xtxinv (clmath:matrix-multiply (transpose-amat x) y))
(defun lstsq (X Y &optional XTXI)
  (setq XTXI (clmath:matrix-multiply (transpose-amat X) X))
  (clmath:matrix-inverse XTXI)
  (clmath:matrix-multiply XTXI (clmath:matrix-multiply (transpose-amat X) Y)))

;; (defvar x (cspl-to-mat '((1 3) (-2 7) (0 1))))
;; (defvar y (cspl-to-mat (cspl 2 1 0)))
;; (defvar beta (lstsq x y))
