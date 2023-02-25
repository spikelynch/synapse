
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


(define node-list '())

; (set! node-list (cons (vec2 100.0 100.0) node-list))
; (set! node-list (cons (vec2 150.0 150.0) node-list))

(define white (make-color 0.9 0.9 0.9 1.0))



(define (paint-node pos)
  (with-style ((fill-color white))
    (fill (circle pos 10))))


(define (paint-nodes nodes)
  (apply superimpose (map paint-node nodes)))



(define (draw alpha)
  (draw-canvas (make-canvas (paint-nodes node-list))))

(define (update dt)
  (let ((dt-seconds (/ dt 1000.0)))
    (update-agenda dt)))
