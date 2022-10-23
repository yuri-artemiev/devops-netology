package main

import "fmt"

func main() {
	// input slice
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	// accept the first element as min
	min := x[0]

	for i := 1; i < len(x); i++ {
		// if current element less than min - redefine min variable
		if min > x[i] {
			min = x[i]
		}
	}
	// print min value
	fmt.Println("Minimal number: ", min)
}
