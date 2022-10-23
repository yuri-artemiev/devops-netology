# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

Послудовательность действий:
- Установи go из репозитория
    ```
    apt install golang-go 
    ```
- Проверим версию
    ```
    go version
    ```
    ```
    go version go1.13.8 linux/amd64
    ```

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main

    import "fmt"

    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)

        output := input * 2

        fmt.Println(output)    
    }
    ```

Последовательность дейтствий:
- Создадим файл `07-05-03-01.go`
    ```
    package main

    import "fmt"

    func main() {
        fmt.Print("Enter length in meteres: ")
        var input float64
        fmt.Scanf("%f", &input)

        output := input * 3.28084

        fmt.Println("Length in feet: ", output)    
    }
    ```
- Скомпилируем и запустим файл `07-05-03-01.go`
    ```
    go run main.go
    ```
    ```
    Enter length in meteres: 10
    Length in feet:  32.8084
    ```
- Cкомпилиурем и запустим файл `07-05-03-01.go`
    ```
    go build 07-05-03-01.go
    ls -lh
    ```
    ```
    -rwxr-xr-x 1 root root 2.1M Oct 23 13:49 07-05-03-01
    -rw-r--r-- 1 root root  217 Oct 23 13:47 07-05-03-01.go
    ```
 
1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
- `07-05-03-02.go`
    ```
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
        fmt.Println(min)
    }
    ```

    
1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.
- `07-05-03-03.go`
    ```
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
    ```


В виде решения ссылку на код или сам код. 

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 
