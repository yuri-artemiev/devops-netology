package main

import "fmt"

func main() {

	// empty slice
	var s []int
	
	for i := 1; i <= 100; i++ {
		// if remainder of a division by 3 equals 0 - append slice s
		if i % 3 == 0 {
			s = append(s, i)
		}		
	}
	// print numbers that are divisible by 3 without a remainder
	fmt.Println(s)
}