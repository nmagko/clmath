;; -*- mode: common-lisp -*-
;;
;; Copyright (C) 2022,2023  Victor C. Salas P.
;;
;; Author: Victor C. Salas P. <nmagko@gmail.com>

;; GAUSS-JORDAN ELIMINATION

(in-package "CLMATH")

(setq *read-default-float-format* 'double-float)

(defun vmul (VX VA &optional (V VX) (M '()))
  (do
   ((i 0 (+ i 1)))
   ((= i (list-length VX))
    M)
    (setq M (append M (list (* (car V) VA))))
    (setq V (cdr V))))

(defun vsum (VX VY &optional (V VX) (W VY) (M '()))
  (do
   ((i 0 (+ i 1)))
   ((= i (list-length VX))
    M)
    (setq M (append M (list (+ (car V) (car W)))))
    (setq V (cdr V))
    (setq W (cdr W))))

(defun zlmn (VX VY PP &optional QX QY)
  (setq QX (nth PP VX))
  (setq QY (nth PP VY))
  (vsum (vmul (vmul VX QY) -1) (vmul VY QX)))

(defun simplify (L LL &optional (S "(gcd") (MP 1) (LZ -1))
  (dolist (i (subseq L 0 LL))
    (if (< LZ 0)
        (if (> i 0) (setq LZ 0)
            (if (< i 0) (setq LZ 1))))
    (setq S (format nil "~a ~a" S i)))
  (setq S (format nil "~a)" S))
  (if (= LZ 1) (setq MP -1))
  (vmul L (/ MP (eval (read-from-string S)))))

(let ((MC '()) (VC 0))
  (defun gauss (AX PX)
    (setq MC '())
    (do
     ((vi 0 (+ vi 1)))
     ((= vi PX)
      (setq MC (append MC (list (nth vi AX)))))
      (setq MC (append MC (list (nth vi AX))))
      )
    (setq VC (nth PX AX))
    (do
     ((vi PX (+ vi 1)))
     ((= vi (- (list-length AX) 1))
      MC)
      (setq MC (append MC (list (zlmn VC (nth (+ vi 1) AX) PX))))
      )
    (if (< PX (- (list-length AX) 2))
        (gauss MC (+ PX 1)))
    MC))

(let ((NC '()) (WC 0))
  (defun jordan (BX RX LL)
    (setq NC '())
    (do
     ((wi (- (list-length BX) 1) (- wi 1)))
     ((= wi RX)
      (setq NC (append (list (simplify (nth wi BX) LL)) NC)))
      (setq NC (append (list (simplify (nth wi BX) LL)) NC))
      )
    (setq WC (nth RX BX))
    (do
     ((wi RX (- wi 1)))
     ((= wi 0)
      NC)
      (setq NC (append (list (simplify (zlmn WC (nth (- wi 1) BX) RX) LL)) NC))
      )
    (if (> RX 1)
        (jordan NC (- RX 1) LL))
    NC))

(defun gauss-jordan (CX &optional DX)
  (setq DX (gauss CX 0))
  (jordan DX (- (list-length DX) 1) (list-length DX)))

;; Gauss-Jordan Elimination Example
;; (defvar a4
;;   '((1 1 0 0 10)
;;     (1 0 1 1 20)
;;     (0 1 1 0 24)
;;     (0 0 2 3 15)))
;; (format t "A4:~%~{~a~%~}SOLVED:~%~{~a~%~}~%" a4 (clmath::gauss-jordan a4))

;; The Inverse Of A Matrix Example
;; |A I|
;; (defvar a4-
;;   '((1 1 0 0 10 1 0 0 0)
;;     (1 0 1 1 20 0 1 0 0)
;;     (0 1 1 0 24 0 0 1 0)
;;     (0 0 2 3 15 0 0 0 1)))
;; |A I| => |I A⁻¹|
;; (format t "A4-:~%~{~a~%~}SOLVED:~%~{~a~%~}~%" a4- (clmath::gauss-jordan a4-))
