#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<time.h>
double cost(double x);
double randbw0_1();
double random_neighbour(double x);
int accept(double deltaE, double T);

double cost(double x)//lets take the cost function as x^2+3*sin(5*x);
{
    double y=x*x;
    return (y*y-10*y+9*x);
}

double randbw0_1()
{
    return (double)rand()/RAND_MAX;
}

double random_neighbour(double x)
{
    double step=randbw0_1()-0.5;
    return (x+step);
}
int accept(double deltaE, double T)
{
    if(deltaE<0) return 1;

    double P=exp(-deltaE/T);
    return randbw0_1()<P;
}

int main()
{
    srand(time(NULL));
    double x=5.0;
    double T=10.0;
    double alpha=0.99;

    for(int i=0;i<5000;i++)
    {
        double new_x=random_neighbour(x);

        double currentE=cost(x);
        double newE=cost(new_x);
        double deltaE=newE-currentE;
        if(accept(deltaE,T))
        {
            x=new_x;
        }
        T=T*alpha;//cooling
    }
    printf("Final answer: %lf\n",x);
    return 1;
}
