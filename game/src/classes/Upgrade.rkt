;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Bullet) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))

(require racket/class)
(require racket/base)
(require "Sprite.rkt")
(require "../resources/media.rkt")
(require 2htdp/image)

(define upgrade% (class sprite%
                  ; Input parameters to give on creation of an asteroid object
                  (init a-Name a-Posn a-SpeedStruct)


                  (super-new 
                    ; Sets the Image based on the %upgrade name given in input
                    (an-Image  (cond
                                    [(string=? a-Name "life")     UPG_LIFE-IMG]
                                    [(string=? a-Name "speedMul") UPG_SPEEDMUL-IMG]
                                    [(string=? a-Name "front")    UPG_FRONT-IMG]
                                    [(string=? a-Name "diagonal") UPG_DIAGONAL-IMG])) 
                    (a-Posn a-Posn)(a-SpeedStruct a-SpeedStruct))
                  
                  (field (name a-Name))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: 
;     random-upgrade :  -> String
;         returns a random  upgrade name based on probability
; Header/Stub 
;     (define/public (random-upgrade) "speedMul")

;Step 4 . Template
;(define (random-upgrade)
;  (local
;    ((define which-upgrade (random ...)))
;    (cond
;      [(<= which-upgrade 10) ...]
;      [(<= which-upgrade 50) ...]
;      [(<= which-upgrade 75) ...]
;      [(<= which-upgrade 100)...] )))


;Step 5 . Code 

(define (random-upgrade)
  (local
    ((define which-upgrade (random 100)))
    (cond
      [(<= which-upgrade 10) "speedMul"]
      [(<= which-upgrade 50) "front"]
      [(<= which-upgrade 75) "diagonal"]
      [(<= which-upgrade 100)"life"] )))

(provide upgrade%)
(provide random-upgrade)

;(new bullet% (an-Image (rectangle 10 10 "solid" "yellow")) (a-Size 10) (a-Posn (make-posn 0 0))(a-SpeedStruct (make-speed 0 -3)))