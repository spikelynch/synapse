
;; todo for today - try to get the chickadee-vat loading and "running"
;; in some sens


(use-modules 
	(chickadee)
 	(chickadee math vector)
 	(chickadee math rect)
 	(chickadee graphics sprite)
 	(chickadee graphics color)
  (chickadee graphics path)
 	(chickadee scripting))


(define drag-line-start #f)
(define drag-line-end #f)


(define (noisy-vec label x y)
  (begin
    (format #t "~a ~a ~a\n" label x y)
    (vec2 x y)))


(define (mouse-press button clicks x y)
  (script
    (if (eq? button 'left)
      (if (not drag-line-start)
        (set! drag-line-start (noisy-vec "start" x y))))))

(define mouse-drag-script
  (script
    (while #t
      (if drag-line-start
        (if (mouse-button-pressed? 'left)
          (let ((mx (mouse-x)) (my (- 480 (mouse-y))))
            (set! drag-line-end (noisy-vec "drag" mx my)))
          (begin 
            (set! drag-line-start #f)
            (set! drag-line-end #f))))
      (sleep 0.02))))


(define (paint-drag-line)
  (with-style ((stroke-color blue) (stroke-width 1))
    (stroke
      (if (and drag-line-start drag-line-end)
        (line drag-line-start drag-line-end)
        (path (move-to (vec2 0.0 0.0)))))))


(define (draw alpha)
  (draw-canvas (make-canvas (paint-drag-line))))

(define (update dt)
  (let ((dt-seconds (/ dt 1000.0)))
    (update-agenda dt)))
