import sys
import os
import time
import json

sys.path.append(os.path.abspath("scripts"))
from figcraft_engine import FigCraftClient

def test_viewports():
    print("================================================================================")
    print(" Artefacta: Multi-Viewport Adaptation Verification (1440 / 1280 / 1024)")
    print("================================================================================")
    
    client = FigCraftClient(mode="ATTACHED")
    export_dir = os.path.abspath("projects/artefacta-museum/exports")
    os.makedirs(export_dir, exist_ok=True)
    
    try:
        # Find root screen and columns
        res_screen = client.run_command("node.find", {"name": "Artefacta_App_Screen_1440x900", "type": "FRAME"})
        res_col1 = client.run_command("node.find", {"name": "Col1_Taxonomy_Sidebar", "type": "FRAME"})
        res_col2 = client.run_command("node.find", {"name": "Col2_Catalog_List", "type": "FRAME"})
        res_col3 = client.run_command("node.find", {"name": "Col3_Dossier_Workspace", "type": "FRAME"})
        
        screen_id = res_screen["ids"][0]
        col1_id = res_col1["ids"][0]
        col2_id = res_col2["ids"][0]
        col3_id = res_col3["ids"][0]
        
        def measure(label):
            time.sleep(0.4)
            n_screen = client.get_node(screen_id)
            n1 = client.get_node(col1_id)
            n2 = client.get_node(col2_id)
            n3 = client.get_node(col3_id)
            
            w_screen = n_screen.get("width")
            w1 = n1.get("width")
            w2 = n2.get("width")
            w3 = n3.get("width")
            print(f"[{label}] Root: {w_screen}px | Col 1 (Sidebar): {w1}px | Col 2 (Catalog): {w2}px | Col 3 (Dossier): {w3}px")
            return {"screen": w_screen, "col1": w1, "col2": w2, "col3": w3}
        
        # 1440x900
        client.run_command("node.set", {"ids": [screen_id], "width": 1440, "height": 900})
        client.run_command("select.none", {})
        m1440 = measure("1440x900 Baseline Desktop")
        shot_1440 = os.path.join(export_dir, "artefacta-native-screen-1440x900.png")
        client.screenshot(shot_1440)
        
        # 1280x800
        client.run_command("node.set", {"ids": [screen_id], "width": 1280, "height": 800})
        client.run_command("select.none", {})
        m1280 = measure("1280x800 Medium Desktop")
        shot_1280 = os.path.join(export_dir, "artefacta-screen-1280x800.png")
        client.screenshot(shot_1280)
        
        # 1024x768
        client.run_command("node.set", {"ids": [screen_id], "width": 1024, "height": 768})
        client.run_command("select.none", {})
        m1024 = measure("1024x768 Compact Desktop")
        shot_1024 = os.path.join(export_dir, "artefacta-screen-1024x768.png")
        client.screenshot(shot_1024)
        
        # Restore 1440x900
        client.run_command("node.set", {"ids": [screen_id], "width": 1440, "height": 900})
        client.run_command("select.none", {})
        time.sleep(0.4)
        client.save_file(os.path.abspath("projects/artefacta-museum/design-system/artefacta-design-system.figcraft"))
        
        print("\nMulti-viewport measurements summary:")
        print(json.dumps({"1440x900": m1440, "1280x800": m1280, "1024x768": m1024}, indent=2))
        return True
    finally:
        client.close()

if __name__ == "__main__":
    test_viewports()
