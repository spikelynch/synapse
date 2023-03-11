
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

(set! node-list (cons (vec2 11.0 0.0) node-list))
(set! node-list (cons (vec2 120.0 15.0) node-list))

(define white (make-color 0.9 0.9 0.9 1.0))


(define (paint-link v1 v2)
  (with-style ((stroke-color green) (stroke-width 1))
    (stroke
      (line v1 v2))))

(define (paint-node-links node)
  (let ((links (list (vec2 100.0 100.0) (vec2 150.0 120.0))))
    (apply superimpose (map (lambda (l) (paint-link node l)) links))))

(define (paint-one-set-of-links)
  (paint-node-links (vec2 20.0 20.0)))

(define (paint-all-links nodes)
  (apply superimpose (map paint-node-links nodes)))


(define (paint-dumb)
  (with-style ((stroke-color red) (stroke-width 1))
    (stroke
      (line (vec2 10.0 10.0) (vec2 80.0 72.0)))))



(define (draw alpha)
  (draw-canvas (make-canvas (paint-all-links node-list))))

(define (update dt)
  (let ((dt-seconds (/ dt 1000.0)))
    (update-agenda dt)))
