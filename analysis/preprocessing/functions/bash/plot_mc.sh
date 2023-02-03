cd ~/checkerboardVASO/data/derivatives/spm_preproc/sub-01/func

cat *notnulled*.txt > rp_notnulled.txt
cat *_nulled*.txt > rp_nulled.txt


gnuplot -persist <<-EOFMarker
	set terminal postscript enhanced color solid  "Helvetica" 10
	set out "motion.ps"
	set key left bottom # for Position of Legend
	set title "Motion across timesteps"   font "Helvetica,10"
	set ylabel "displacement in mm"  font "Helvetica,10"
	set xlabel "|time in TR"  font "Helvetica,10"
	set size ratio 0.6

	plot 	"rp_nulled.txt" u 0:1  with lines  title "nulled x"  linecolor rgb "green" ,\
		"rp_nulled.txt" u 0:2  with lines  title "nulled y"  linecolor rgb "red" ,\
		"rp_nulled.txt" u 0:3  with lines  title "nulled z"  linecolor rgb "brown" ,\
		"rp_notnulled.txt" u 0:1  with lines  title "not_nulled x"  linecolor rgb "turquoise" ,\
		"rp_notnulled.txt" u 0:2  with lines  title "not_nulled y"  linecolor rgb "pink" ,\
		"rp_notnulled.txt" u 0:3  with lines  title "not_nulled z"  linecolor rgb "black" 
EOFMarker

paste rp_notnulled.txt rp_nulled.txt  | awk '{print $1-$7,$2-$8,$3-$9,$4-$10,$5-$11,$6-$12}' > rp_diff.txt

gnuplot -persist <<-EOFMarker
	set terminal postscript enhanced color solid  "Helvetica" 10
	set out "motion_diff.ps"
	set key left bottom # for Position of Legend
	set title "Motion diff across timesteps"   font "Helvetica,10"
	set ylabel "difference in displacement in mm"  font "Helvetica,10"
	set xlabel "|time in TR"  font "Helvetica,10"
	set size ratio 0.6

	plot 	"rp_diff.txt" u 0:1  with lines  title "notnulled - nulled x"  linecolor rgb "green" ,\
		"rp_diff.txt" u 0:2  with lines  title "notnulled - nulled y"  linecolor rgb "red" ,\
		"rp_diff.txt" u 0:3  with lines  title "notnulled - nulled z"  linecolor rgb "blue" 
EOFMarker

rm *run*.txt

