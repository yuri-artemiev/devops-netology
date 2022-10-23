package main

import "fmt"

func main() {
    fmt.Print("Enter length in meteres: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input * 3.28084

    fmt.Println("Length in feet: ", output)    
}
