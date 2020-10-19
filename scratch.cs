using System;

namespace cSharpTest
{
    class scratch
    {
        static void Main(string[] args)
        {
            double[] tmpArray = { 445.12057,445.11612,445.12502};
            int errTol = 2;
            int ppmTol = 10;
            for (int j = 0; j < tmpArray.LongLength; j++)
            {
                double val = tmpArray[j];
                double ppmValA = val * (1 + ppmTol * 1e-6);
                double ppmValB = val * (1 - ppmTol * 1e-6);
                double tmpVal = Math.Round(val, errTol, MidpointRounding.AwayFromZero);
                double tmpValA = Math.Round(ppmValA, errTol, MidpointRounding.AwayFromZero);
                double tmpValB = Math.Round(ppmValB, errTol, MidpointRounding.AwayFromZero);
                /*
                double tmpVal = Math.Round(val, errTol, MidpointRounding.ToZero);
                double tmpValA = Math.Round(ppmValA, errTol, MidpointRounding.ToZero);
                double tmpValB = Math.Round(ppmValB, errTol, MidpointRounding.ToZero);
                double tmpVal = Math.Round(val, errTol, MidpointRounding.ToEven);
                double tmpValA = Math.Round(ppmValA, errTol, MidpointRounding.ToEven);
                double tmpValB = Math.Round(ppmValB, errTol, MidpointRounding.ToEven);
                */
                Console.WriteLine("{0}\t{1}\t{2}", tmpVal, tmpValA, tmpValB);
            }
        }
    }
}
