


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




(define on-sprite #f)
(define off-sprite #f)


(define drag-line-start #f)
(define drag-line-end #f)
(define drag-node #f)

(define (fix-mouse-y)
  (- (window-height (current-window)) (mouse-y)))


(define neuron-agenda (make-agenda))
(define ui-agenda (make-agenda))


(define (^neuron bcom name threshold value pos connections)
  (methods
    ((get-value) value)
    ((get-name) name)
    ((get-connections) connections)
    ((get-pos) pos)
    ((connect neuron)
      (begin
        (format #t "[~a] adding connection to [~a]\n" name ($ neuron 'get-name))
        (bcom (^neuron bcom name threshold value pos (cons neuron connections)))))
    ((receive input)
      (define new-value (+ value input))
      (if (>= new-value threshold)
        (begin
          (for-each (lambda (n) ($ n 'receive 1)) connections)
          (bcom (^neuron bcom name threshold 0 pos connections)))
        (bcom (^neuron bcom name threshold new-value pos connections))))))


(define my-vat (make-chickadee-vat #:agenda neuron-agenda))

(vat-start! my-vat)


(define nodes '())

(define clock-neuron #f)

(define (reset!)
  (set! nodes '()))


(define white (make-color 1.0 1.0 1.0 0.78))
(define color-off (make-color 1.0 1.0 1.0 0))

(define node-width 30)

(define link-color (rgba #x003040))
(define link-width 1)


(define (node-bbox pos)
  (let ((x (- (vec2-x pos) node-width))
        (y (- (vec2-y pos) node-width))
        (width (* 2 node-width)))
    (rect x y width width)))

(define* (create-node name pos threshold)
	(list
    (cons 'neuron (with-vat my-vat (spawn ^neuron name threshold 0 pos '())))
    (cons 'name name)
		(cons 'pos pos)
    (cons 'bbox (node-bbox pos))
		(cons 'threshold threshold)
		(cons 'value 0)
    (cons 'links '())
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
  (with-agenda neuron-agenda
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
                  (assoc-set! n 'color (node-color n)))))
              nodes))
        (sleep 0.02)))))


(define links-script
  (with-agenda neuron-agenda
    (script
     (while #t
      (with-vat my-vat
        (for-each (lambda (n)
          (let ((neuron (assoc-ref n 'neuron)))
            (assoc-set! n 'links 
              (map
                (lambda (c) ($ c 'get-pos))
                ($ neuron 'get-connections)))))
          nodes)
        (sleep 0.1))))))


(define (update-links)
  (for-each (lambda (n)
    (let ((neuron (assoc-ref n 'neuron)))
      (assoc-set! n 'links 
        (map
          (lambda (c) ($ c 'get-pos))
            ($ neuron 'get-connections)))))
  nodes))



;; load isn't working for me with chickadee play
(define (load)
  (format #t "load was called!"))






(define mouse-drag-script
  (with-agenda ui-agenda
    (script
      (while #t
        (if drag-line-start
          (let ((mx (mouse-x)) (my (fix-mouse-y)))
            (if (mouse-button-pressed? 'left)
              (set! drag-line-end (vec2 mx my))
              (let ((target (point-in-node mx my)))
                (if (not (nil? target))
                  (add-link! drag-node (car target)))
                (set! drag-node #f) 
                (set! drag-line-start #f)
                (set! drag-line-end #f)))))
        (sleep 0.02)))))



(define (add-link! source target)
  (let ((source-n (assoc-ref source 'neuron))
        (target-n (assoc-ref target 'neuron)))
    (if (not (eq? source target))
      (with-vat my-vat
        ($ source-n 'connect target-n)
        (update-links)))))


(define (start-drag! node)
  (let ((pos (assoc-ref node 'pos)))
    (set! drag-node node)
    (set! drag-line-start pos)))



(define (point-in-node x y)
  (filter (lambda (n)
    (rect-contains-vec2? (assoc-ref n 'bbox) (vec2 x y)))
    nodes))
  


(define (mouse-press button clicks x y)
  (let ((node-name (format #f "(~a,~a)" x y))
        (in-node (point-in-node x y))
        (is-first (nil? nodes)))
      (with-agenda ui-agenda
        (script
          (if (eq? button 'left)
            (if (nil? in-node)
              (add-node! node-name (vec2 x y) 4)
              (start-drag! (car in-node))))))))






(define (paint-node node)
  (with-style ((stroke-color (node-color node)) (stroke-width 5))
    (stroke (circle (assoc-ref node 'pos) node-width))))


(define (paint-nodes nodes)
  (apply superimpose (map paint-node nodes)))


(define (paint-link v1 v2)
  (with-style ((stroke-color link-color) (stroke-width link-width))
    (stroke (line v1 v2))))


;; returns a list of paths of edges from this node
(define (paint-node-links node)
  (let ((links (assoc-ref node 'links))
        (posn (assoc-ref node 'pos)))
    (apply superimpose (map (lambda (l) (paint-link posn l)) links))))

(define (paint-links nodes)
  (apply superimpose (map paint-node-links nodes)))


(define (paint-drag-line)
  (with-style ((stroke-color blue) (stroke-width 1))
    (stroke
      (if (and drag-line-start drag-line-end)
        (line drag-line-start drag-line-end)
        (path (move-to (vec2 0.0 0.0)))))))


(define (draw alpha)
  (draw-canvas (make-canvas
    (superimpose
      (paint-drag-line)
      (paint-links nodes)
      (paint-nodes nodes)))))

(define (update dt)
  (let ((dt-seconds (/ dt 1000.0)))
    (current-agenda neuron-agenda)
    (update-agenda dt)
    (current-agenda ui-agenda)
    (update-agenda dt)))


