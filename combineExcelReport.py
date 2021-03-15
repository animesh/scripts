#https://towardsdatascience.com/automate-your-boring-excel-reporting-with-python-cb18d1ecce14
import pandas as pd
import glob
from openpyxl import load_workbook
from openpyxl.styles import Font
from openpyxl.chart import BarChart, Reference
file_path = r"*.xlsx"
files = glob.glob(file_path)

print(files)
# Create empty dataframe
df = pd.DataFrame()

# Loop over list
for file in files:
    temp_df = pd.read_excel(file)

    # Create a column with the filename
    temp_df['Name'] = file

    # Clean up the column name a bit
    temp_df['Name'] = temp_df['Name'].str.replace('/Users/nik/Desktop/ExcelMagic/', '')
    temp_df['Name'] = temp_df['Name'].str.replace('.xlsx', '')

    # Append temporary dataframe to df
    df = df.append(temp_df, ignore_index=True)
pivot = pd.pivot_table(
    data=df,
    index='Name',
    columns=df['Date'].dt.quarter,
    values='Price',
    aggfunc='sum',
)
save_file_path = '/Users/nikpi/Desktop/Summary.xlsx'
pivot.to_excel(save_file_path, sheet_name='Summary')
wb = load_workbook(save_file_path)
sheet = wb['Summary']

# Format values as currencies
for column in ['B', 'C', 'D', 'E']:
    for row in range(2, 9):
        sheet[f'{column}{row}'].style = 'Currency'

# Add a bar graph of data
bar_chart = BarChart()
data = Reference(sheet, min_col=2, max_col=5, min_row=1, max_row=8)
categories = Reference(sheet, min_col=1, max_col=1, min_row=1, max_row=8)
bar_chart.add_data(data, titles_from_data=True)
bar_chart.set_categories(categories)
bar_chart.title = 'Sales by Person and Quarter'
sheet.add_chart(bar_chart, "G2")

# Save your data
wb.save(save_file_path)


use strict;
use Spreadsheet::Read;
my $id=0;
my %vh;
my %nh;
my %ch;

sub createhash{
	my $f1 = shift;
	my $data  = ReadData ($f1);
	my @lin=cell2cr($data->[1]{cell}[1][3]);#->[1]{$c};
	my $line;
	my $lc;
	print "$f1\t$data\n";
	#for(my $c=0;$c<=$#data;$c++){
	for(my $c=0;$c<=10;$c++){
		$lc++;
		#$lc=$lin[1][1];
		$line =~ s/\r//g;
		chomp $line;
		print "@lin\t";
		if($lc==1){$vh{$f1}="$line";}
		else{
			my @tmp;#=parse_line(',',0,$line);
			if ($tmp[$id] ne ""){
				$nh{$tmp[$id]}++;
				$ch{"$tmp[$id]-$f1"}++;
				$vh{"$tmp[$id]-$f1"}=$line;
			}
		}
	}
}

for(my $c=0;$c<=$#ARGV;$c++){
	my $fn=createhash($ARGV[$c]);
}


my $lc;

#print "ID,Total,";
for(my $c=0;$c<=$#ARGV;$c++){
	#print "$vh{$ARGV[$c]},InFile,";
}
#print "Total\n";

foreach my $ncc (keys %nh){
	$lc++;
	print "$ncc,$nh{$ncc},";
	for(my $c=0;$c<=$#ARGV;$c++){
		my $name="$ncc-$ARGV[$c]";
		print "$vh{$name},$ch{$name},";
	}
	print "$nh{$ncc}\n";
}

__END__

$ perl filecomb.pl /cygdrive/l/Elite/gaute/HAMR/hamrcomb.xls /cygdrive/l/Elite/gaute/HAMR/hamrcomb.txt /cygdrive/l/Elite/gaute/HAMR/hamrcomb.csv /cygdrive/l/Elite/gaute/HAMR/hamrcomb.xlsx
/cygdrive/l/Elite/gaute/HAMR/hamrcomb.xls       ARRAY(0x6018b5d18)
/cygdrive/l/Elite/gaute/HAMR/hamrcomb.txt
/cygdrive/l/Elite/gaute/HAMR/hamrcomb.csv       ARRAY(0x6027d4828)
/cygdrive/l/Elite/gaute/HAMR/hamrcomb.xlsx      ARRAY(0x6022084d8)
ID,Total,,InFile,,InFile,,InFile,,InFile,Total
