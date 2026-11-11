# Previous Heart Attack Detection from the ECG

Course project for ELEC 447 at Koç University, done with Berke Sevindik. Can an ECG alone tell whether someone has had a heart attack in the past?

![Detected R-peaks and Q-points on a 12-lead recording](docs/images/r_and_q_peaks.png)

A heart attack (myocardial infarction, MI) leaves a lasting mark on the ECG: a deeper Q wave just before the main spike of each beat. Many past heart attacks are silent and go unnoticed, so finding this mark on a routine ECG is useful.

We used the PTB Diagnostic ECG Database (PhysioNet). Each 12-lead recording is band-pass filtered (0.5–40 Hz) and normalized, every beat's R-peak and the Q point before it are located, and the Q-wave amplitude becomes the feature. A single threshold on that amplitude did not separate the groups because people differ too much, so the final version uses a support vector machine with an RBF kernel, evaluated with leave-one-out cross-validation.

| Q amplitude, healthy vs previous MI | SVM decision |
|---|---|
| ![Q amplitude scatter](docs/images/q_amplitude_scatter.png) | ![SVM decision](docs/images/svm_decision.png) |

![Confusion matrix](docs/images/confusion_matrix.png)

The method, results and discussion are in [`docs/ELEC447_Project_Report.pdf`](docs/ELEC447_Project_Report.pdf). The dataset is small (a few dozen patients per group after cleaning), so this is a course-level proof of concept.

## Files

```
matlab/Project.m                final pipeline: Q-wave features, SVM, leave-one-out validation
matlab/threshold_classifier.m   first attempt with a single Q-amplitude threshold
matlab/process_dat_file.m       reads PTB .dat/.hea records
python/sort_ptb_records.py      sorts PTB records into groups
python/confusion_and_metrics.py confusion matrix and metric plots
docs/                           report and images
```

## Data

The PTB Diagnostic ECG Database is not included. Download it from https://physionet.org/content/ptbdb/, sort it with `python/sort_ptb_records.py`, and place the group folders (for example `data/Controls_Corrected` and `data/Only_previous_Corrected`) next to the scripts. Citation: Bousseljot, R., Kreiseler, D., Schnabel, A., "Nutzung der EKG-Signaldatenbank CARDIODAT der PTB über das Internet," Biomedizinische Technik, 1995.

---

Yaşar Aykut Altuntop · Koç University · [LinkedIn](https://linkedin.com/in/aykutaltuntop) · [GitHub](https://github.com/Aykut0)
