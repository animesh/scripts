using System;
using LinqInfer;
namespace cSharpTest
{
    class scratch
    {
        static void Main(string[] args)
        {
            // https://github.com/roberino/linqinfer Sample space

            var sampleSpace = queryableSampleDataset.AsSampleSpace();

            var p = sampleSpace.ProbabilityOfEvent(p => p.Age > 25);

            // Hypotheses

            var die = new[] { 4, 6, 8, 12, 20 };
            var hypos = die.Select(n => P.Of(n).Is(1).OutOf(die.Length)).AsHypotheses();

            hypos.Update(x => x < 6 ? Fraction.Zero : (1).OutOf(x));

            hypos.ProbabilityOf(4);
        }
    }
}
