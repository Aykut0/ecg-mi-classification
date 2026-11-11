import os
import shutil

# Load the list of controls
def load_controls(filepath):
    controls = set()
    with open(filepath, 'r') as file:
        for line in file:
            # Each line has the format: patientXXX/sXXXXlre
            patient_folder = line.split('/')[0]  # Extract only 'patientXXX'
            controls.add(patient_folder)  # Add the patient folder to the set
    return controls

# Parse infarction data from a .hea file
def parse_infarction_data(hea_file):
    infarction_data = {
        "acute": "n/a",
        "previous_1": "n/a",
        "previous_2": "n/a",
        "healthy_control": "n/a"
    }
    try:
        with open(hea_file, 'r') as file:
            for line in file:
                if "# Infarction date (acute):" in line:
                    infarction_data["acute"] = line.split(":")[-1].strip()
                elif "# Previous infarction (1) date:" in line:
                    infarction_data["previous_1"] = line.split(":")[-1].strip()
                elif "# Previous infarction (2) date:" in line:
                    infarction_data["previous_2"] = line.split(":")[-1].strip()
                elif "# Reason for admission:" in line:
                    infarction_data["healthy_control"] = line.split(":")[-1].strip()
    except Exception as e:
        print(f"Error reading {hea_file}: {e}")
    return infarction_data

# Categorize based on infarction data
def categorize_patient(infarction_data):
    acute = infarction_data["acute"]
    previous_1 = infarction_data["previous_1"]
    previous_2 = infarction_data["previous_2"]
    control = infarction_data["healthy_control"] 
    if control == "Healthy control":
        return "Controls"
    if acute != "n/a":
        if previous_1 == "n/a" and previous_2 == "n/a":
            return "Acute only"
        elif previous_1 != "n/a" and previous_2 == "n/a":
            return "Acute and one previous"
        elif previous_1 != "n/a" and previous_2 != "n/a":
            return "Acute and two previous"
    elif acute == "n/a":
        if previous_1 != "n/a" or previous_2 != "n/a":
            return "Only previous"
    #elif controls

    return "Uncategorized"

# Process database and copy .dat files
def process_database(base_path, controls, output_base_path):
    results = {
        "Acute only": [],
        "Acute and one previous": [],
        "Acute and two previous": [],
        "Only previous": [],
        "Uncategorized": [],
        "Controls": []
    }

    for category in results.keys():
        category_path = os.path.join(output_base_path, category)
        os.makedirs(category_path, exist_ok=True)

    for patient_folder in os.listdir(base_path):
        if patient_folder in controls:
            control_path = os.path.join(base_path, patient_folder)
            for file in os.listdir(control_path):
                
                file_path = os.path.join(control_path, file)
                if file.endswith(".hea") and os.path.isfile(file_path):    
                    infarction_data = parse_infarction_data(file_path)
                    category = categorize_patient(infarction_data)
                    results[category].append(patient_folder)
                    # Create the patient's folder under the category
                    patient_output_folder = os.path.join(output_base_path, category, patient_folder)
                    print(f"Checking file: {patient_output_folder}")
                    os.makedirs(patient_output_folder, exist_ok=True)
                    # Copy the .hea file to the patient's folder under the correct category
                    dest_hea_p = os.path.join(patient_output_folder, file)
                    
                    shutil.copy(file_path, dest_hea_p)
                     # Copy the corresponding .dat file to the output folder
                    dat_fi = file.replace(".hea", ".dat")  # Get the corresponding .dat file name
                    dat_file_p = os.path.join(control_path, dat_fi)
        
                    if os.path.isfile(dat_file_p):
                        dest_dat_p = os.path.join(output_base_path, category, patient_folder, dat_fi)
                        shutil.copy(dat_file_p, dest_dat_p)
                
            continue  # Skip controls

        patient_path = os.path.join(base_path, patient_folder)
        if not os.path.isdir(patient_path):
            continue

        for file in os.listdir(patient_path):
            file_path = os.path.join(patient_path, file)
    
            # Process only .hea files
            if file.endswith(".hea") and os.path.isfile(file_path):
        
                # Parse infarction data from the .hea file
                infarction_data = parse_infarction_data(file_path)
                category = categorize_patient(infarction_data)
                results[category].append(patient_folder)
                
                # Create the patient's folder under the category
                patient_output_folder = os.path.join(output_base_path, category, patient_folder)
                os.makedirs(patient_output_folder, exist_ok=True)
                
                # Copy the .hea file to the patient's folder under the correct category
                dest_hea_path = os.path.join(patient_output_folder, file)
                shutil.copy(file_path, dest_hea_path)
                
                # Copy the corresponding .dat file to the output folder
                dat_file = file.replace(".hea", ".dat")  # Get the corresponding .dat file name
                dat_file_path = os.path.join(patient_path, dat_file)

                if os.path.isfile(dat_file_path):
                    dest_dat_path = os.path.join(output_base_path, category, patient_folder, dat_file)
                    shutil.copy(dat_file_path, dest_dat_path)
    return results

# Main function
def main():
    controls_path = "data/ptb-diagnostic-ecg-database-1.0.0/CONTROLS"  # Path to controls file
    database_path = "data/ptb-diagnostic-ecg-database-1.0.0"  # Replace with actual database path
    output_base_path = "data/Output"  # Replace with actual output path

    controls = load_controls(controls_path)
    results = process_database(database_path, controls, output_base_path)

    for category, records in results.items():
        print(f"{category}: {len(records)} records")
        for record in records:
            print(f"  - {record}")

if __name__ == "__main__":
    main()

    
     