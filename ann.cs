using System;
using System.Diagnostics;
namespace ANN4CS
{
    class Program
    {
        static void Mainn(string[] args)
        {
            System.Random random = new System.Random();
            Console.WriteLine("parameter count = {0}", args.Length);
            double[] input = new double[] { 0.05, 0.1 };
            double[,] inpw = new double[,] { { 0.15, 0.20 }, { 0.25, 0.3 } };
            double[] hidden = new double[2];
            double[,] hidw = new double[,] { { 0.4, 0.45 }, { 0.5, 0.55 } };
            double[] outputc = new double[2];
            double[] outputr = new double[] { 0.01, 0.99 };
            double[] bias = new double[] { 0.35, 0.6 };
            double[] cons = new double[] { 1, 1 };
            for (int j = 0; j < inpw.GetLength(0); j++)
            {
                double collin = 0;
                for (int i = 0; i < input.Length; i++)
                {
                    Debug.Write(input[i] + Environment.NewLine + inpw[j, i] + Environment.NewLine);
                    collin += inpw[j, i] * input[i];
                }
                collin += bias[0] * cons[0];
                collin = 1 / (1 + Math.Pow(Math.E, -1*collin));
                Debug.Write(Environment.NewLine + collin + Environment.NewLine);
                hidden[j] = collin;
            }
            double error = 0;
            for (int j = 0; j < hidw.GetLength(0); j++)
            {
                double collin = 0;
                for (int i = 0; i < hidden.Length; i++)
                {
                    Debug.Write(hidden[i] + Environment.NewLine + hidw[j, i] + Environment.NewLine);
                    collin += hidw[j, i] * hidden[i];
                }
                collin += bias[1] * cons[1];
                collin = 1 / (1 + Math.Pow(Math.E, -collin));
                Debug.Write(Environment.NewLine + collin + Environment.NewLine);
                outputc[j] = collin;
                error += Math.Pow(outputr[j] - outputc[j],2)/2;
                Debug.Write(j+Environment.NewLine + error + Environment.NewLine);
            }
            //Debug.Write(Environment.NewLine + error + Environment.NewLine);
            Console.WriteLine("Error = {0}", error);
            matrix myMatrix = new matrix();
        }
    }
    class matrix
    {
        public int rownum { get; set; }
    }
}
