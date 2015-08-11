using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

using MSFileReaderLib;  /* add reference XRawfile2_x64.dll from http://sjsupport.thermofinnigan.com/public/detail.asp?id=703 */

namespace RawRead{
    class RawRead2PeakList    {
        static void Main(string[] args){
            MSFileReader_XRawfile rawMSfile = new MSFileReader_XRawfile();
            rawMSfile.Open("L:\\Davi\\_QE\\BSAs\\20150512_BSA_The-PEG-envelope.raw");
            rawMSfile.SetCurrentController(0, 1); /* Controller type 0 means mass spec device; Controller 1 means first MS device */
            int nms = 0; /* ref int usrd with GetNumSpectra */
            int pbMSData=0;
            int pnLastSpectrum=0;
            rawMSfile.GetNumSpectra(ref nms);
            rawMSfile.IsThereMSData(ref pbMSData);
            rawMSfile.GetLastSpectrumNumber(ref pnLastSpectrum);
            Debug.WriteLine("Total Spectra: " + nms);
            Debug.WriteLine("MSdata: " + pbMSData);
            Debug.WriteLine("Last MSdata: " + pnLastSpectrum);
            double pkWidCentroid = 0.0;
            object mzList = null;
            object pkFlg = null;
            int arrLen = 0;
            for (int i = 1; i < 10; i++){
                rawMSfile.GetMassListFromScanNum(i, null, 1, 0, 0, 0, ref pkWidCentroid, ref mzList, ref pkFlg, ref arrLen);
                double[,] mslist = (double[,])mzList;
                //for (int j = 0; j < 2; j++){
                    Debug.WriteLine("MSdata: " + mslist[0,i] + "MSdata: " + mslist[1,i] + "Scan:" + i);
                //}
            }
        }
    }
}

// source http://bioinfo.kouwua.net/2012/09/read-thermo-raw-with-msfilereader-in-c.html

