
;; todo for today - try to get the chickadee-vat loading and "running"
;; in some sens


(use-modules 
	(chickadee)
 	(chickadee math vector)
 	(chickadee math rect)
 	(chickadee graphics sprite)
 	(chickadee graphics color)
  (chickadee graphics path)
 	(chickadee scripting)
  (goblins)
  (goblins actor-lib cell)
  (goblins actor-lib methods)
  (synapse chickadee-vat))



(define window-width 800)
(define window-height 600)

(define on-sprite #f)
(define off-sprite #f)



(define (^neuron bcom name threshold value connections)
  (methods
    ((get-value) value)
    ((get-name) name)
    ((get-connections) connections)
    ((connect neuron)
      (begin
        (format #t "[~a] adding connection to [~a]\n" name ($ neuron 'get-name))
        (bcom (^neuron bcom name threshold value (cons neuron connections)))))
    ((receive input)
      (define new-value (+ value input))
      (if (>= new-value threshold)
        (begin
          (for-each (lambda (n) ($ n 'receive 1)) connections)
          (bcom (^neuron bcom name threshold 0 connections)))
        (bcom (^neuron bcom name threshold new-value connections))))))


(define my-vat (make-chickadee-vat #:agenda (current-agenda)))

(vat-start! my-vat)


(define nodes '())

(define clock-neuron #f)

(define (reset!)
  (set! nodes '()))


(define white (make-color 1.0 1.0 1.0 0.78))
(define color-off (make-color 1.0 1.0 1.0 0))


(define* (create-node name pos threshold)
	(list
    (cons 'neuron (with-vat my-vat (spawn ^neuron name threshold 0 '())))
    (cons 'name name)
		(cons 'pos pos)
		(cons 'threshold threshold)
		(cons 'value 0)
    (cons 'color color-off)))

(define (add-node! name pos threshold)
  (let ((new-node (create-node name pos threshold)))
    (begin
      (if (nil? nodes)
        (set! clock-neuron (assoc-ref new-node 'neuron)))
      (set! nodes (cons new-node nodes)))))


(define (draw-node node)
  (draw-sprite
  	(if (assoc-ref node 'value) on-sprite off-sprite)
   	(assoc-ref node 'pos)))

(set! on-sprite (load-image "assets/on.png"))
(set! off-sprite (load-image "assets/off.png"))


(define (node-color node)
  (let ((percent (/ (assoc-ref node 'value) (assoc-ref node 'threshold)))
        (red (/ (vec2-x (assoc-ref node 'pos)) 800.0)))
    (make-color red 0.2 0.2 (+ 0.2 (* 0.8 percent)))))

(define clock-script
    (script
     (while #t
      (with-vat my-vat
        (begin
          (if clock-neuron
            ($ clock-neuron 'receive 1)))
          (for-each (lambda (n)
            (let ((neuron (assoc-ref n 'neuron)))
              (begin
                (assoc-set! n 'value ($ neuron 'get-value))
                (assoc-set! n 'color (node-color n))
                )))
            nodes))
       (sleep 0.05))))


;; load isn't working for me with chickadee play
(define (load)
  (format #t "load was called!"))

(define (mouse-press button clicks x y)
  (let ((node-name (format #f "(~a,~a)" x y))
        (is-first (nil? nodes)))
    (script
      (add-node! node-name (vec2 x y) 4)
      (if (not is-first)
        (begin
          (format #t "connecting new node\n")
          (let ((last-n (assoc-ref (cadr nodes) 'neuron))
                (new-n (assoc-ref (car nodes) 'neuron)))
            (with-vat my-vat
              ($ last-n 'connect new-n))))))))




(define (paint-node node)
  (with-style ((stroke-color (node-color node)) (stroke-width 5))
    (stroke (circle (assoc-ref node 'pos) (+ 10 (* 8 (assoc-ref node 'value)))))))

(define (paint-node-fill node)
  (with-style (
    (fill-color (node-color node))
    (stroke-color (node-color node))
    (stroke-width 5))
    (fill-and-stroke
      (circle (assoc-ref node 'pos) (+ 10 (* 5 (assoc-ref node 'value)))))))


(define (paint-nodes nodes)
  (apply superimpose (map paint-node nodes)))

(define (draw alpha)
  (draw-canvas (make-canvas (paint-nodes nodes))))

(define (update dt)
  (let ((dt-seconds (/ dt 1000.0)))
    (update-agenda dt)))



