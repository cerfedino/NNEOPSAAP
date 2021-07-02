;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Asteroid) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))

;Libraries
(require racket/class)
(require racket/base)
(require "Sprite.rkt")
(require "../resources/media.rkt")


;Step 1: Data types
; a speed is a structure (make-speed x y ))
;    where x  : Posn
;          y  : Posn
; interpretation: a struct representing the speed of the asteroid
(define-struct speed [x y])

(define asteroid% (class sprite%
                  ; Input parameters to give on creation of an asteroid object
                  (init an-Image a-Posn a-SpeedStruct)

                  (super-new (an-Image an-Image)(a-Posn a-Posn)(a-SpeedStruct a-SpeedStruct))

                  ; called when the asteroid gets hit
                  (define/public (hit)
                    (ASTEROID_HIT_SFX))))

                  

(provide asteroid%)
;(new asteroid% (an-Image asteroid-image)(a-Size 100)(a-Posn (make-posn 0 0))(make-speed 0 20))