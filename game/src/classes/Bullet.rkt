;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Bullet) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;Libraries
(require racket/class)
(require racket/base)
(require "Sprite.rkt")



(define bullet% (class sprite%
                  ; Input parameters to give on creation of an asteroid object
                  (init an-Image a-Posn a-SpeedStruct)

                  (super-new 
                    (an-Image  an-Image) 
                    (a-Posn a-Posn)(a-SpeedStruct a-SpeedStruct))

                  ))

(provide bullet%)

;(new bullet% (an-Image (rectangle 10 10 "solid" "yellow")) (a-Size 10) (a-Posn (make-posn 0 0))(a-SpeedStruct (make-speed 0 -3)))