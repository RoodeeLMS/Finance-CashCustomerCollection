import zipfile
import os

# Create zip file
zip_path = 'THFinanceCashCollection_1_0_0_3_Complete.zip'
source_dir = 'extracted'

with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    # Add root files
    zipf.write(os.path.join(source_dir, '[Content_Types].xml'), '[Content_Types].xml')
    zipf.write(os.path.join(source_dir, 'customizations.xml'), 'customizations.xml')
    zipf.write(os.path.join(source_dir, 'solution.xml'), 'solution.xml')

    # Add CanvasApps folder
    for filename in os.listdir(os.path.join(source_dir, 'CanvasApps')):
        file_path = os.path.join(source_dir, 'CanvasApps', filename)
        zipf.write(file_path, f'CanvasApps/{filename}')

    # Add Workflows folder
    for filename in os.listdir(os.path.join(source_dir, 'Workflows')):
        file_path = os.path.join(source_dir, 'Workflows', filename)
        zipf.write(file_path, f'Workflows/{filename}')

print(f'Created {zip_path} successfully')
print('Files included:')
with zipfile.ZipFile(zip_path, 'r') as zipf:
    for name in zipf.namelist():
        print(f'  {name}')
