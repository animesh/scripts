#source https://www.bruker.com/protected/en/services/software-downloads/mass-spectrometry/raw-data-access-libraries.html
import sys
if len(sys.argv)!=2:    sys.exit("USAGE: python pepCountTTP.py <path to MSn containing directory>, \n e.g.,\npython pepCountTTP.py \"F:/promec/LARS/TIMSTOF/Morten/210902 Morten 1 _Slot1-37_1_176.d\"\n")
#python pepCountTTP.py "C:/Users/animeshs/HeLaReps/230301_hela_Slot1-54_1_3996.d"
analysis_dir = sys.argv[1]
analysis_dir = "C:/Users/animeshs/HeLaReps/230301_hela_Slot1-54_1_3996.d"
import sqlite3, sys, time
import numpy as np, matplotlib.pyplot as plt
import numpy as np
import sqlite3
import os, sys
from ctypes import *
libname = "C:/Users/animeshs/timsdata-2.21.0.4/timsdata/win64/timsdata.dll"
#libname = "libtimsdata.so"
dll = cdll.LoadLibrary(libname)
dll.tims_open.argtypes = [ c_char_p, c_uint32 ]
dll.tims_open.restype = c_uint64
dll.tims_close.argtypes = [ c_uint64 ]
dll.tims_close.restype = None
dll.tims_get_last_error_string.argtypes = [ c_char_p, c_uint32 ]
dll.tims_get_last_error_string.restype = c_uint32
dll.tims_has_recalibrated_state.argtypes = [ c_uint64 ]
dll.tims_has_recalibrated_state.restype = c_uint32
dll.tims_read_scans_v2.argtypes = [ c_uint64, c_int64, c_uint32, c_uint32, c_void_p, c_uint32 ]
dll.tims_read_scans_v2.restype = c_uint32
MSMS_SPECTRUM_FUNCTOR = CFUNCTYPE(None, c_int64, c_uint32, POINTER(c_double), POINTER(c_float))
dll.tims_read_pasef_msms.argtypes = [ c_uint64, POINTER(c_int64), c_uint32, MSMS_SPECTRUM_FUNCTOR ]
dll.tims_read_pasef_msms.restype = c_uint32
dll.tims_read_pasef_msms_for_frame.argtypes = [ c_uint64, c_int64, MSMS_SPECTRUM_FUNCTOR ]
dll.tims_read_pasef_msms_for_frame.restype = c_uint32
MSMS_PROFILE_SPECTRUM_FUNCTOR = CFUNCTYPE(None, c_int64, c_uint32, POINTER(c_int32))
dll.tims_read_pasef_profile_msms.argtypes = [ c_uint64, POINTER(c_int64), c_uint32, MSMS_PROFILE_SPECTRUM_FUNCTOR ]
dll.tims_read_pasef_profile_msms.restype = c_uint32
dll.tims_read_pasef_profile_msms_for_frame.argtypes = [ c_uint64, c_int64, MSMS_PROFILE_SPECTRUM_FUNCTOR ]
dll.tims_read_pasef_profile_msms_for_frame.restype = c_uint32

dll.tims_extract_centroided_spectrum_for_frame.argtypes = [ c_uint64, c_int64, c_uint32, c_uint32, MSMS_SPECTRUM_FUNCTOR, c_void_p ]
dll.tims_extract_centroided_spectrum_for_frame.restype = c_uint32
dll.tims_extract_profile_for_frame.argtypes = [ c_uint64, c_int64, c_uint32, c_uint32, MSMS_PROFILE_SPECTRUM_FUNCTOR, c_void_p ]
dll.tims_extract_profile_for_frame.restype = c_uint32

convfunc_argtypes = [ c_uint64, c_int64, POINTER(c_double), POINTER(c_double), c_uint32 ]

dll.tims_index_to_mz.argtypes = convfunc_argtypes
dll.tims_index_to_mz.restype = c_uint32
dll.tims_mz_to_index.argtypes = convfunc_argtypes
dll.tims_mz_to_index.restype = c_uint32

dll.tims_scannum_to_oneoverk0.argtypes = convfunc_argtypes
dll.tims_scannum_to_oneoverk0.restype = c_uint32
dll.tims_oneoverk0_to_scannum.argtypes = convfunc_argtypes
dll.tims_oneoverk0_to_scannum.restype = c_uint32

dll.tims_scannum_to_voltage.argtypes = convfunc_argtypes
dll.tims_scannum_to_voltage.restype = c_uint32
dll.tims_voltage_to_scannum.argtypes = convfunc_argtypes
dll.tims_voltage_to_scannum.restype = c_uint32

dll.tims_oneoverk0_to_ccs_for_mz.argtypes = [c_double, c_int32, c_double]
dll.tims_oneoverk0_to_ccs_for_mz.restype = c_double

dll.tims_ccs_to_oneoverk0_for_mz.argtypes = [c_double, c_int32, c_double]
dll.tims_ccs_to_oneoverk0_for_mz.restype = c_double

def throwLastTimsDataError (dll_handle):
    """Throw last TimsData error string as an exception."""

    len = dll_handle.tims_get_last_error_string(None, 0)
    buf = create_string_buffer(len)
    dll_handle.tims_get_last_error_string(buf, len)
    raise RuntimeError(buf.value)

# Decodes a properties BLOB of type 12 (array of strings = concatenation of
# zero-terminated UTF-8 strings). (The BLOB object returned by an SQLite query can be
# directly put into this function.) \returns a list of unicode strings.
def decodeArrayOfStrings (blob):
    if blob is None:
        return None # property not set

    if len(blob) == 0:
        return [] # empty list

    blob = bytearray(blob)
    if blob[-1] != 0:
        raise ValueError("Illegal BLOB contents.") # trailing nonsense

    if sys.version_info.major == 2:
        return unicode(str(blob), 'utf-8').split('\0')[:-1]
    if sys.version_info.major == 3:
        return str(blob, 'utf-8').split('\0')[:-1]
        

# Convert 1/K0 to CCS for a given charge and mz
def oneOverK0ToCCSforMz(ook0, charge, mz):
    return dll.tims_oneoverk0_to_ccs_for_mz(ook0, charge, mz)

# Convert CCS to 1/K0 for a given charge and mz
def ccsToOneOverK0ToCCSforMz(ccs, charge, mz):
    return dll.tims_ccs_to_oneoverk0_for_mz(ccs, charge, mz)
       
        
class TimsData:

    def __init__ (self, analysis_directory, use_recalibrated_state=False):

        if sys.version_info.major == 2:
            if not isinstance(analysis_directory, unicode):
                raise ValueError("analysis_directory must be a Unicode string.")
        if sys.version_info.major == 3:
            if not isinstance(analysis_directory, str):
                raise ValueError("analysis_directory must be a string.")

        self.dll = dll

        self.handle = self.dll.tims_open(
            analysis_directory.encode('utf-8'),
            1 if use_recalibrated_state else 0 )
        if self.handle == 0:
            throwLastTimsDataError(self.dll)

        self.conn = sqlite3.connect(os.path.join(analysis_directory, "analysis.tdf"))

        self.initial_frame_buffer_size = 128 # may grow in readScans()

    def __del__ (self):
        if hasattr(self, 'handle'):
            self.dll.tims_close(self.handle)         
            
    def __callConversionFunc (self, frame_id, input_data, func):

        if type(input_data) is np.ndarray and input_data.dtype == np.float64:
            # already "native" format understood by DLL -> avoid extra copy
            in_array = input_data
        else:
            # convert data to format understood by DLL:
            in_array = np.array(input_data, dtype=np.float64)

        cnt = len(in_array)
        out = np.empty(shape=cnt, dtype=np.float64)
        success = func(self.handle, frame_id,
                       in_array.ctypes.data_as(POINTER(c_double)),
                       out.ctypes.data_as(POINTER(c_double)),
                       cnt)

        if success == 0:
            throwLastTimsDataError(self.dll)

        return out

    def indexToMz (self, frame_id, indices):
        return self.__callConversionFunc(frame_id, indices, self.dll.tims_index_to_mz)
        
    def mzToIndex (self, frame_id, mzs):
        return self.__callConversionFunc(frame_id, mzs, self.dll.tims_mz_to_index)
        
    def scanNumToOneOverK0 (self, frame_id, scan_nums):
        return self.__callConversionFunc(frame_id, scan_nums, self.dll.tims_scannum_to_oneoverk0)

    def oneOverK0ToScanNum (self, frame_id, mobilities):
        return self.__callConversionFunc(frame_id, mobilities, self.dll.tims_oneoverk0_to_scannum)

    def scanNumToVoltage (self, frame_id, scan_nums):
        return self.__callConversionFunc(frame_id, scan_nums, self.dll.tims_scannum_to_voltage)

    def voltageToScanNum (self, frame_id, voltages):
        return self.__callConversionFunc(frame_id, voltages, self.dll.tims_voltage_to_scannum)

        
    # Output: list of tuples (indices, intensities)
    def readScans (self, frame_id, scan_begin, scan_end):

        # buffer-growing loop
        while True:
            cnt = int(self.initial_frame_buffer_size) # necessary cast to run with python 3.5
            buf = np.empty(shape=cnt, dtype=np.uint32)
            len = 4 * cnt

            required_len = self.dll.tims_read_scans_v2(self.handle, frame_id, scan_begin, scan_end,
                                                    buf.ctypes.data_as(POINTER(c_uint32)),
                                                    len)
            if required_len == 0:
                throwLastTimsDataError(self.dll)

            if required_len > len:
                if required_len > 16777216:
                    # arbitrary limit for now...
                    raise RuntimeError("Maximum expected frame size exceeded.")
                self.initial_frame_buffer_size = required_len / 4 + 1 # grow buffer
            else:
                break

        result = []
        d = scan_end - scan_begin
        for i in range(scan_begin, scan_end):
            npeaks = buf[i-scan_begin]
            indices     = buf[d : d+npeaks]
            d += npeaks
            intensities = buf[d : d+npeaks]
            d += npeaks
            result.append((indices,intensities))

        return result

    # read some peak-picked MS/MS spectra for a given list of precursors; returns a dict mapping
    # 'precursor_id' to a pair of arrays (mz_values, area_values).
    def readPasefMsMs (self, precursor_list):
        precursors_for_dll = np.array(precursor_list, dtype=np.int64)

        result = {}

        @MSMS_SPECTRUM_FUNCTOR
        def callback_for_dll(precursor_id, num_peaks, mz_values, area_values):
            result[precursor_id] = (mz_values[0:num_peaks], area_values[0:num_peaks])
        
        rc = self.dll.tims_read_pasef_msms(self.handle,
                                           precursors_for_dll.ctypes.data_as(POINTER(c_int64)),
                                           len(precursor_list),
                                           callback_for_dll)

        if rc == 0:
            throwLastTimsDataError(self.dll)
        
        return result

		# read peak-picked MS/MS spectra for a given frame; returns a dict mapping
    # 'precursor_id' to a pair of arrays (mz_values, area_values).
    def readPasefMsMsForFrame (self, frame_id):
        result = {}

        @MSMS_SPECTRUM_FUNCTOR
        def callback_for_dll(precursor_id, num_peaks, mz_values, area_values):
            result[precursor_id] = (mz_values[0:num_peaks], area_values[0:num_peaks])
        
        rc = self.dll.tims_read_pasef_msms_for_frame(self.handle,
                                           frame_id,
                                           callback_for_dll)

        if rc == 0:
            throwLastTimsDataError(self.dll)
        
        return result
        
		# read some "quasi profile" MS/MS spectra for a given list of precursors; returns a dict mapping
    # 'precursor_id' to the profil arrays (intensity_values).
    def readPasefProfileMsMs (self, precursor_list):
        precursors_for_dll = np.array(precursor_list, dtype=np.int64)

        result = {}

        @MSMS_PROFILE_SPECTRUM_FUNCTOR
        def callback_for_dll(precursor_id, num_points, intensity_values):
            result[precursor_id] = intensity_values[0:num_points]
        
        rc = self.dll.tims_read_pasef_profile_msms(self.handle,
                                           precursors_for_dll.ctypes.data_as(POINTER(c_int64)),
                                           len(precursor_list),
                                           callback_for_dll)

        if rc == 0:
            throwLastTimsDataError(self.dll)
        
        return result
                
    # read "quasi profile" MS/MS spectra for a given frame; returns a dict mapping
    # 'precursor_id' to the profil arrays (intensity_values).
    def readPasefProfileMsMsForFrame (self, frame_id):
        result = {}

        @MSMS_PROFILE_SPECTRUM_FUNCTOR
        def callback_for_dll(precursor_id, num_points, intensity_values):
            result[precursor_id] = intensity_values[0:num_points]
        
        rc = self.dll.tims_read_pasef_profile_msms_for_frame(self.handle,
                                           frame_id,
                                           callback_for_dll)

        if rc == 0:
            throwLastTimsDataError(self.dll)
        
        return result
        
    # read peak-picked spectra for a tims frame;
    # returns a pair of arrays (mz_values, area_values).
    def extractCentroidedSpectrumForFrame (self, frame_id, scan_begin, scan_end):
        result = None

        @MSMS_SPECTRUM_FUNCTOR
        def callback_for_dll(precursor_id, num_peaks, mz_values, area_values):
            nonlocal result
            result = (mz_values[0:num_peaks], area_values[0:num_peaks])
        
        rc = self.dll.tims_extract_centroided_spectrum_for_frame(
                                           self.handle,
                                           frame_id,
                                           scan_begin,
                                           scan_end,
                                           callback_for_dll,
                                           None) # python dos not need the additional context, we have nonlocal

        if rc == 0:
            throwLastTimsDataError(self.dll)
        
        return result
        
    # read "quasi profile" spectra for a tims frame;
    # returns the profil array (intensity_values).
    def extractProfileForFrame (self, frame_id, scan_begin, scan_end):
        result = None

        @MSMS_PROFILE_SPECTRUM_FUNCTOR
        def callback_for_dll(precursor_id, num_points, intensity_values):
            nonlocal result
            result = intensity_values[0:num_points]
        
        rc = self.dll.tims_extract_profile_for_frame(
                                           self.handle,
                                           frame_id,
                                           scan_begin,
                                           scan_end,
                                           callback_for_dll,
                                           None) # python dos not need the additional context, we have nonlocal

        if rc == 0:
            throwLastTimsDataError(self.dll)
        
        return result
#convert 1/K0 to CCS
#ccs = TimsData.oneOverK0ToCCS(1.1846, 1, 946.7764)
#print("CCS for 1/K0 1.1846, charge 1, mass 946.7764 : {0}".format(ccs))

td = TimsData(analysis_dir)
conn = td.conn

# Get total frame count:
q = conn.execute("SELECT COUNT(*) FROM Frames")
row = q.fetchone()
N = row[0]
print(analysis_dir,"has {0} frames.".format(N))


# Get a projected mass spectrum:
frame_id = 10
q = conn.execute("SELECT NumScans FROM Frames WHERE Id={0}".format(frame_id))
num_scans = q.fetchone()[0]

numplotbins = 500;
min_mz = 0
max_mz = 3000
mzbins = np.linspace(min_mz, max_mz, numplotbins)
midmz = (mzbins[0:numplotbins-1] + mzbins[1:numplotbins]) / 2
summed_intensities = np.zeros(numplotbins+1)

for scan in td.readScans(frame_id, 0, num_scans):
    index = np.array(scan[0], dtype=np.float64)
    mz = td.indexToMz(frame_id, index)
    if len(mz) > 0:
        plotbins = np.digitize(mz, mzbins)
        intens = scan[1]
        for i in range(0, len(intens)):
            summed_intensities[plotbins[i]] += intens[i]
scan_number_axis = np.arange(num_scans, dtype=np.float64)

ook0_axis = td.scanNumToOneOverK0(frame_id, scan_number_axis)
scan_number_from_ook0_axis = td.oneOverK0ToScanNum(frame_id, ook0_axis)
voltage_axis = td.scanNumToVoltage(frame_id, scan_number_axis)
scan_number_from_voltage_axis = td.voltageToScanNum(frame_id, voltage_axis)
print(scan_number_axis[0], scan_number_axis[-1])
print(ook0_axis[0], ook0_axis[-1], scan_number_from_ook0_axis[0], scan_number_from_ook0_axis[-1])
print(voltage_axis[0], voltage_axis[-1], scan_number_from_voltage_axis[0], scan_number_from_voltage_axis[-1])
#plt.stem(midmz, summed_intensities[1:numplotbins])
