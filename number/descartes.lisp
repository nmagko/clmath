;; -*- mode: common-lisp -*-
;;
;; Copyright (C) 2026  Victor C. Salas P.
;;
;; Author: Victor C. Salas P. <nmagko@gmail.com>

;; DESCARTES' THEOREM

;; It connects the physical world of shapes with abstract algebra and
;; number theory. the theorem provides a precise, numerical relationship
;; between four mutually tangent circles (or spheres in 3D). Instead of
;; thinking about a circle's radius (which is a length), the theorem uses
;; its curvature (or "bend"), defined as

;;     b = ±1/r

;; - Positive curvature (+1/r) means the circle/sphere is convex (like a
;; - standard ball).  Negative curvature (−1/r) is used for a circle/sphere
;; - that contains all the others (like the outer boundary of a gasket).

;; If four circles are all touching each other, and their curvatures are
;; b₁, b₂, b₃, b₄, the theorem states they must satisfy this surprisingly
;; simple quadratic equation:

;;     (b₁ + b₂ + b₃ + b₄)² = 2 · (b₁² + b₂² + b₃² + b₄²)

;; If you know the curvatures of the first three circles (b₁, b₂, b₃), you
;; can solve this equation to find the curvature of the fourth circle (b₄)
;; that fits perfectly in the gap between them. You actually get two
;; possible answers for b₄: one for the circle that fits in the small gap,
;; and one for the giant circle that wraps around all three.

(in-package "CLMATH")

;; -- CIRCLES 2D --
(defun descartes (b1 b2 b3)
  "Solve for the two possible curvatures (b4) given
   three mutually tangent ones."
  (let ((s (+ b1 b2 b3))
        (r (* 2 (sqrt (+ (* b1 b2) (* b1 b3) (* b2 b3))))))
    (values (+ s r) (- s r))))

;; -- SPHERES 3D --
;; The 3D Descartes-Gossett theorem:
;;     3 · (sum)² = sum of squares of curvatures
;; Rearranged for b₅: 
;;     3 · (sum + b₅)² = sum_squares + b₅²
;;     2 · b₅² + 6 · sum · b₅ + (3 · sum² - sum_squares) = 0
(defun descartes-3d (b1 b2 b3 b4)
  "Solve for the two possible 5th curvatures in 3D.
   Returns two values: b5a and b5b."
  (let* ((sum (+ b1 b2 b3 b4))
         (sum-sq (expt sum 2))
         (sum-sq-squares (+ (expt b1 2) (expt b2 2) 
                            (expt b3 2) (expt b4 2)))
         (a 2.0)
         (b (* 6.0 sum))
         (c (- (* 3.0 sum-sq) sum-sq-squares))
         (discriminant (- (expt b 2) (* 4 a c))))
    ;; Return the two roots
    (if (>= discriminant 0)
        (let ((sqrt-disc (sqrt discriminant)))
          (values (/ (- (- b) sqrt-disc) (* 2 a))
                  (/ (+ (- b) sqrt-disc) (* 2 a))))
        (error "No real solution for these curvatures"))))
