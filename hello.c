#include <iostream.h>
int main()
{
    int grade, sum, n, average;

    n = 0;
    sum = 0;
    while (n < 5) {
        cout << "Enter a grade" << endl;
        cin >> grade;
        sum = sum + grade;
        n++;
    }
    average = sum / 5;
    cout << "The average is " << average << endl;
    return 0;
}
