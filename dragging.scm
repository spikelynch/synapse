
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

(define flasher-state #t)

(define main-agenda (make-agenda))
(define drag-agenda (make-agenda))

(define (fix-mouse-y)
  (- (window-height (current-window)) (mouse-y)))

(define (mouse-press button clicks x y)
  (script
    (if (eq? button 'left)
      (if (not drag-line-start)
        (set! drag-line-start (vec2 x y))))))

(define mouse-drag-script
  (with-agenda drag-agenda
    (script
      (while #t
        (if drag-line-start
          (if (mouse-button-pressed? 'left)
            (let ((mx (mouse-x)) (my (fix-mouse-y)))
              (set! drag-line-end (vec2 mx my)))
            (begin 
              (set! drag-line-start #f)
              (set! drag-line-end #f))))
        (sleep 0.02)))))


(define flasher-script
  (with-agenda main-agenda
    (script
      (while #t
        (set! flasher-state (not flasher-state))
        (sleep 1.0)))))


(define (paint-drag-line)
  (with-style ((stroke-color blue) (stroke-width 1))
    (stroke
      (if (and drag-line-start drag-line-end)
        (line drag-line-start drag-line-end)
        (path (move-to (vec2 0.0 0.0)))))))

(define (paint-flasher)
  (with-style ((fill-color (if flasher-state green white)))
    (fill (circle (vec2 100.0 100.0) 20.0))))

(define (draw alpha)
  (draw-canvas (make-canvas 
    (superimpose (paint-flasher) (paint-drag-line)))))

(define (update dt)
  (let ((dt-seconds (/ dt 1000.0)))
    (current-agenda drag-agenda)
    (update-agenda dt)
    (current-agenda main-agenda)
    (update-agenda dt)))
