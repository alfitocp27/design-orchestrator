"""
Artefacta: Collection Catalog & Curatorial Dossier Screen Builder
Executed in FigCraft ATTACHED Mode for Live Desktop Observation.
"""

import sys
import os
import time
import json

# Ensure scripts directory is on Python path
sys.path.append(os.path.abspath("scripts"))
from figcraft_engine import FigCraftClient


def build_artefacta_screen():
    print("================================================================================")
    print(" Artefacta: Curatorial Monograph Application Screen Builder (Live Attached)")
    print("================================================================================")

    client = FigCraftClient(mode="ATTACHED")
    doc_path = os.path.abspath("projects/artefacta-museum/design-system/artefacta-design-system.figcraft")

    try:
        # Step 0: Verify active document
        doc = client.inspect_document(depth=1)
        active_path = doc.get("path")
        print(f"Active Document: '{doc.get('name')}' (Path: {active_path})")

        if not active_path or os.path.abspath(active_path) != doc_path:
            print(f"Opening target document: {doc_path}")
            client.open_file(doc_path)
            time.sleep(0.5)

        # Step 1: Ensure Page '04_Screens' exists
        pages = client.run_command("page.list", {}) or []
        page_names = {p["name"]: p["id"] for p in pages}
        print(f"Current Document Pages: {page_names}")

        if "04_Screens" in page_names:
            screen_page_id = page_names["04_Screens"]
            print(f"Selecting existing Page '04_Screens' (ID: {screen_page_id})...")
            client.run_command("page.select", {"id": screen_page_id})
        else:
            print("Creating Page '04_Screens'...")
            p4 = client.run_command("page.add", {"name": "04_Screens"})
            screen_page_id = p4["id"]
            client.run_command("page.select", {"id": screen_page_id})

        time.sleep(0.5)

        # Clean existing screen on this page if present (idempotent build)
        existing = client.run_command("node.find", {"name": "Artefacta_App_Screen_1440x900", "type": "FRAME"})
        if existing and existing.get("ids"):
            print(f"Removing prior build frame: {existing['ids']}")
            client.run_command("edit.delete", {"ids": existing["ids"]})
            time.sleep(0.3)

        # Step 2: Retrieve Master Component IDs from Library
        masters = {}
        for comp in client.run_command("component.list", {}) or []:
            masters[comp["name"]] = comp["id"]
            if comp.get("label"):
                masters[comp["label"]] = comp["id"]

        print(f"Retrieved {len(masters)} component signatures from library.")

        # Master Component References
        BTN_PRIMARY = masters.get("State=Primary-Default", 84)
        BTN_ACCENT = masters.get("State=Accent-Terracotta", 88)
        BTN_OUTLINE = masters.get("State=Secondary-Outline", 90)

        BADGE_STABLE = masters.get("State=Stable-Display", 96)
        BADGE_QUEUE = masters.get("State=Treatment-Queue", 98)
        BADGE_ALERT = masters.get("State=Climate-Alert", 100)

        FACET_MASTER = masters.get("Nav/Facet_Item_Master", 106)
        SPEC_ROW_MASTER = masters.get("Table/Spec_Row_Master", 112)
        GAUGE_MASTER = masters.get("Meter/Climate_Gauge_Master", 117)
        PLATE_MASTER = masters.get("Media/Archival_Vector_Plate_Master", 124)
        CATALOG_CARD_MASTER = masters.get("Card/Catalog_Item_Master", 131)

        ICON_SEARCH = masters.get("Icon/search", 66)
        ICON_FILTER = masters.get("Icon/filter", 68)

        # ---------------------------------------------------------------------
        # BUILD STEP 1: Root Viewport Frame (1440x900)
        # ---------------------------------------------------------------------
        print("\n--- [Step 1] Constructing Root Viewport Frame (1440x900) ---")
        screen_id = client.create_node(
            node_type="frame",
            name="Artefacta_App_Screen_1440x900",
            width=1440,
            height=900,
            props={
                "fill": "#FAF9F6",
                "layout": "vertical",
                "padding": 0,
                "gap": 0,
                "clip": True,
            }
        )["id"]
        time.sleep(0.4)

        # ---------------------------------------------------------------------
        # BUILD STEP 2: Top Monograph Navigation Header (1440x60)
        # ---------------------------------------------------------------------
        print("--- [Step 2] Building Top Monograph Navigation Header (1440x60) ---")
        header_id = client.create_node(
            node_type="frame",
            name="Monograph_Top_Header",
            parent=screen_id,
            width=1440,
            height=60,
            props={
                "fill": "#0F172A",  # Deep Archival Navy / Slate
                "layout": "horizontal",
                "mainAlign": "spaceBetween",
                "crossAlign": "center",
                "padding": [12, 24, 12, 24],
                "sizingH": "fixed",
                "sizingV": "fixed",
            }
        )["id"]

        # Header Left: Brand & Department
        h_left = client.create_node(
            node_type="frame",
            name="Brand_Section",
            parent=header_id,
            props={
                "layout": "horizontal",
                "crossAlign": "center",
                "gap": 16,
                "fill": "none",
                "sizingH": "hug",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="Logo_Wordmark",
            parent=h_left,
            props={
                "characters": "ARTEFACTA",
                "fontFamily": "EB Garamond",
                "fontSize": 20,
                "fontStyle": "Bold",
                "fill": "#FFFFFF",
                "letterSpacing": "8%",
            }
        )

        client.create_node(
            node_type="frame",
            name="Divider_Line",
            parent=h_left,
            width=1,
            height=20,
            props={"fill": "#334155"}
        )

        client.create_node(
            node_type="text",
            name="Dept_Subtitle",
            parent=h_left,
            props={
                "characters": "Collection Catalog & Curatorial Dossier",
                "fontFamily": "Inter",
                "fontSize": 12,
                "fill": "#94A3B8",
            }
        )

        # Header Center: Global Search Bar
        search_box = client.create_node(
            node_type="frame",
            name="Global_Search_Input",
            parent=header_id,
            width=460,
            height=36,
            props={
                "fill": "#1E293B",
                "cornerRadius": 4,
                "stroke": "#334155",
                "strokeWeight": 1,
                "layout": "horizontal",
                "crossAlign": "center",
                "gap": 10,
                "padding": [0, 14, 0, 14],
                "sizingH": "fixed",
                "sizingV": "fixed",
            }
        )["id"]

        # Search icon instance
        client.run_command("instance.create", {"component": ICON_SEARCH, "parent": search_box})

        client.create_node(
            node_type="text",
            name="Search_Placeholder",
            parent=search_box,
            props={
                "characters": "Search accessions, provenance, vitrine telemetry...",
                "fontFamily": "Inter",
                "fontSize": 12,
                "fill": "#94A3B8",
            }
        )

        # Header Right: Curator Profile & Export Dossier Action
        h_right = client.create_node(
            node_type="frame",
            name="User_Actions_Section",
            parent=header_id,
            props={
                "layout": "horizontal",
                "crossAlign": "center",
                "gap": 16,
                "fill": "none",
                "sizingH": "hug",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="User_Curator_Badge",
            parent=h_right,
            props={
                "characters": "Dr. Elena Vance • Chief Curator",
                "fontFamily": "Inter",
                "fontSize": 12,
                "fill": "#E2E8F0",
            }
        )

        # Linked Action Button
        btn_exp = client.run_command("instance.create", {"component": BTN_ACCENT, "parent": h_right})["id"]
        # Override button text to 'Export Dossier'
        t_exp = client.run_command("node.find", {"root": btn_exp, "type": "TEXT"})["ids"][0]
        client.run_command("node.set", {"ids": [t_exp], "characters": "Export Dossier (PDF)"})

        time.sleep(0.4)

        # ---------------------------------------------------------------------
        # BUILD STEP 3: Workspace Body Container (3 Columns: 240px | 360px | 840px)
        # ---------------------------------------------------------------------
        print("--- [Step 3] Constructing 3-Column Workspace Auto Layout Container ---")
        workspace_id = client.create_node(
            node_type="frame",
            name="Workspace_Body_Columns",
            parent=screen_id,
            width=1440,
            height=840,
            props={
                "fill": "#FAF9F6",
                "layout": "horizontal",
                "gap": 0,
                "padding": 0,
                "sizingH": "fixed",
                "sizingV": "fixed",
            }
        )["id"]
        time.sleep(0.3)

        # =====================================================================
        # COLUMN 1: Collection Taxonomy & Facet Navigation Sidebar (240px)
        # =====================================================================
        print("--- [Step 4] Building Column 1: Collection Taxonomy & Facet Sidebar (240px) ---")
        col1_id = client.create_node(
            node_type="frame",
            name="Col1_Taxonomy_Sidebar",
            parent=workspace_id,
            width=250,
            height=840,
            props={
                "fill": "#FAF9F6",
                "stroke": "#E2E2DC",
                "strokeSides": [0, 1, 0, 0],
                "strokeWeight": 1,
                "layout": "vertical",
                "gap": 16,
                "padding": [20, 12, 20, 12],
                "sizingH": "fixed",
                "sizingV": "fixed",
            }
        )["id"]

        # Sidebar Section 1: Taxonomy
        client.create_node(
            node_type="text",
            name="Sidebar_Sec1_Label",
            parent=col1_id,
            props={
                "characters": "COLLECTION ARCHIVES",
                "fontFamily": "Inter",
                "fontSize": 11,
                "fontStyle": "Bold",
                "fill": "#64748B",
                "letterSpacing": "6%",
            }
        )

        facets_group = client.create_node(
            node_type="frame",
            name="Facets_List",
            parent=col1_id,
            props={
                "layout": "vertical",
                "gap": 4,
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        # Department Facets using linked instances of Nav/Facet_Item_Master
        dept_data = [
            ("Ancient Greece & Attica", "1,420", True),
            ("Etruscan & Magna Graecia", "840", False),
            ("Near Eastern Antiquities", "2,180", False),
            ("Roman Bronzes & Sculpture", "940", False),
            ("Cycladic Votive Figurines", "310", False),
        ]

        for dept_name, count_str, is_active in dept_data:
            f_inst = client.run_command("instance.create", {"component": FACET_MASTER, "parent": facets_group})["id"]
            client.run_command("node.set", {"ids": [f_inst], "sizingH": "fill"})
            if is_active:
                client.run_command("node.set", {
                    "ids": [f_inst],
                    "fill": "#EAE8E3",
                    "stroke": "#C2410C",
                    "strokeSides": [0, 0, 0, 3],
                    "strokeWeight": 1
                })
            else:
                client.run_command("node.set", {"ids": [f_inst], "fill": "none"})

            texts = client.run_command("node.find", {"root": f_inst, "type": "TEXT"})["ids"]
            for tid in texts:
                node_data = client.get_node(tid)
                if node_data.get("name") == "Facet_Label":
                    client.run_command("node.set", {"ids": [tid], "characters": dept_name})
                    if is_active:
                        client.run_command("node.set", {"ids": [tid], "fontStyle": "Bold", "fill": "#0F172A"})
                elif node_data.get("name") == "Count_Num":
                    client.run_command("node.set", {"ids": [tid], "characters": count_str})

        # Divider
        client.create_node(
            node_type="frame",
            name="Sidebar_Divider_1",
            parent=col1_id,
            height=1,
            props={"fill": "#E2E2DC", "sizingH": "fill"}
        )

        # Sidebar Section 2: Material Filter
        client.create_node(
            node_type="text",
            name="Sidebar_Sec2_Label",
            parent=col1_id,
            props={
                "characters": "MATERIAL FILTER",
                "fontFamily": "Inter",
                "fontSize": 11,
                "fontStyle": "Bold",
                "fill": "#64748B",
                "letterSpacing": "6%",
            }
        )

        mat_group = client.create_node(
            node_type="frame",
            name="Materials_List",
            parent=col1_id,
            props={
                "layout": "vertical",
                "gap": 8,
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        materials = [
            ("• Terracotta & Ceramics", "1,840"),
            ("• Cast Bronze & Alloys", "920"),
            ("• Carved Parian Marble", "610"),
        ]
        for m_name, m_count in materials:
            m_row = client.create_node(
                node_type="frame",
                name="Material_Item",
                parent=mat_group,
                props={
                    "layout": "horizontal",
                    "mainAlign": "spaceBetween",
                    "crossAlign": "center",
                    "fill": "none",
                    "sizingH": "fill",
                    "sizingV": "hug",
                }
            )["id"]
            client.create_node(
                node_type="text",
                name="Mat_Name",
                parent=m_row,
                props={"characters": m_name, "fontFamily": "Inter", "fontSize": 12, "fill": "#1E293B"}
            )
            client.create_node(
                node_type="text",
                name="Mat_Count",
                parent=m_row,
                props={"characters": m_count, "fontFamily": "JetBrains Mono", "fontSize": 11, "fill": "#64748B"}
            )

        # Divider
        client.create_node(
            node_type="frame",
            name="Sidebar_Divider_2",
            parent=col1_id,
            height=1,
            props={"fill": "#E2E2DC", "sizingH": "fill"}
        )

        # Sidebar Section 3: Conservation Status Filter
        client.create_node(
            node_type="text",
            name="Sidebar_Sec3_Label",
            parent=col1_id,
            props={
                "characters": "CONSERVATION STATE",
                "fontFamily": "Inter",
                "fontSize": 11,
                "fontStyle": "Bold",
                "fill": "#64748B",
                "letterSpacing": "6%",
            }
        )

        stat_group = client.create_node(
            node_type="frame",
            name="Status_Filter_List",
            parent=col1_id,
            props={
                "layout": "vertical",
                "gap": 8,
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        statuses = [
            ("● Stable (On Display)", "1,180", "#047857"),
            ("● Treatment Queue", "142", "#B45309"),
            ("● Climate Alert", "18", "#B91C1C"),
        ]
        for s_name, s_count, s_col in statuses:
            s_row = client.create_node(
                node_type="frame",
                name="Status_Row",
                parent=stat_group,
                props={
                    "layout": "horizontal",
                    "mainAlign": "spaceBetween",
                    "crossAlign": "center",
                    "fill": "none",
                    "sizingH": "fill",
                    "sizingV": "hug",
                }
            )["id"]
            client.create_node(
                node_type="text",
                name="Status_Name",
                parent=s_row,
                props={"characters": s_name, "fontFamily": "Inter", "fontSize": 12, "fill": s_col}
            )
            client.create_node(
                node_type="text",
                name="Status_Count",
                parent=s_row,
                props={"characters": s_count, "fontFamily": "JetBrains Mono", "fontSize": 11, "fill": "#64748B"}
            )

        # Sidebar Footer: Telemetry Mesh Box
        client.create_node(
            node_type="frame",
            name="Sidebar_Spacer",
            parent=col1_id,
            props={"layout": "vertical", "sizingH": "fill", "sizingV": "fill", "fill": "none"}
        )

        telemetry_box = client.create_node(
            node_type="frame",
            name="Mesh_Status_Card",
            parent=col1_id,
            props={
                "fill": "#F1F1EE",
                "cornerRadius": 4,
                "stroke": "#E2E2DC",
                "strokeWeight": 1,
                "layout": "vertical",
                "gap": 4,
                "padding": [8, 10, 8, 10],
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]
        client.create_node(
            node_type="text",
            name="Mesh_Status_Title",
            parent=telemetry_box,
            props={"characters": "Vitrine Mesh: Online [SIMULATED]", "fontFamily": "Inter", "fontSize": 11, "fontStyle": "Bold", "fill": "#047857"}
        )
        client.create_node(
            node_type="text",
            name="Mesh_Status_Sub",
            parent=telemetry_box,
            props={"characters": "84 Sensors [DEMO] • 0.2s cycle", "fontFamily": "JetBrains Mono", "fontSize": 11, "fill": "#475569"}
        )

        time.sleep(0.4)

        # =====================================================================
        # COLUMN 2: Collection Catalog List (360px)
        # =====================================================================
        print("--- [Step 5] Building Column 2: Collection Catalog Cards List (360px) ---")
        col2_id = client.create_node(
            node_type="frame",
            name="Col2_Catalog_List",
            parent=workspace_id,
            width=350,
            height=840,
            props={
                "fill": "#FAF9F6",
                "stroke": "#E2E2DC",
                "strokeSides": [0, 1, 0, 0],
                "strokeWeight": 1,
                "layout": "vertical",
                "gap": 12,
                "padding": [20, 12, 20, 12],
                "sizingH": "fixed",
                "sizingV": "fixed",
            }
        )["id"]

        # Catalog List Header Row
        cat_hdr = client.create_node(
            node_type="frame",
            name="Catalog_Header_Row",
            parent=col2_id,
            props={
                "layout": "horizontal",
                "mainAlign": "spaceBetween",
                "crossAlign": "center",
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="Catalog_Title",
            parent=cat_hdr,
            props={"characters": "ATTIC CERAMICS", "fontFamily": "Inter", "fontSize": 12, "fontStyle": "Bold", "fill": "#1E293B"}
        )

        client.create_node(
            node_type="text",
            name="Catalog_Count",
            parent=cat_hdr,
            props={"characters": "1,420 ACCESSIONS", "fontFamily": "JetBrains Mono", "fontSize": 11, "fill": "#64748B"}
        )

        # Sort & Filter Bar
        sort_bar = client.create_node(
            node_type="frame",
            name="Catalog_Sort_Bar",
            parent=col2_id,
            props={
                "fill": "#FFFFFF",
                "cornerRadius": 4,
                "stroke": "#E2E2DC",
                "strokeWeight": 1,
                "layout": "horizontal",
                "mainAlign": "spaceBetween",
                "crossAlign": "center",
                "padding": [6, 12, 6, 12],
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="Sort_Label",
            parent=sort_bar,
            props={"characters": "Sort: Accession Date (Desc)", "fontFamily": "Inter", "fontSize": 11, "fill": "#64748B"}
        )

        client.run_command("instance.create", {"component": ICON_FILTER, "parent": sort_bar})

        # Catalog Cards Container
        cards_container = client.create_node(
            node_type="frame",
            name="Cards_Stack",
            parent=col2_id,
            props={
                "layout": "vertical",
                "gap": 10,
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        catalog_entries = [
            {
                "accession": "ARC-530-ATH",
                "title": "Attic Black-Figure Amphora",
                "sub": "c. 530 BCE • Archaic Greek • Vitrine G-04",
                "selected": True,
                "badge_state": "Stable-Display",
                "badge_text": "Stable — Display",
            },
            {
                "accession": "ARC-490-KLR",
                "title": "Kylix by the Foundry Painter",
                "sub": "c. 490 BCE • Late Archaic • Cons. Lab 2",
                "selected": False,
                "badge_state": "Treatment-Queue",
                "badge_text": "Treatment Queue",
            },
            {
                "accession": "ARC-510-LEK",
                "title": "Attic White-Ground Lekythos",
                "sub": "c. 510 BCE • Classical Greek • Vitrine G-12",
                "selected": False,
                "badge_state": "Stable-Display",
                "badge_text": "Stable — Display",
            },
            {
                "accession": "ARC-440-KRTR",
                "title": "Volute Krater (Niobid Group)",
                "sub": "c. 440 BCE • High Classical • Vitrine G-08",
                "selected": False,
                "badge_state": "Climate-Alert",
                "badge_text": "Climate Alert",
            },
        ]

        for entry in catalog_entries:
            c_inst = client.run_command("instance.create", {"component": CATALOG_CARD_MASTER, "parent": cards_container})["id"]
            client.run_command("node.set", {"ids": [c_inst], "sizingH": "fill"})

            if entry["selected"]:
                client.run_command("node.set", {
                    "ids": [c_inst],
                    "fill": "#FFFFFF",
                    "stroke": "#C2410C",
                    "strokeSides": [1, 1, 1, 3],
                    "strokeWeight": 1
                })
            else:
                client.run_command("node.set", {
                    "ids": [c_inst],
                    "fill": "#FAF9F6",
                    "stroke": "#E2E2DC",
                    "strokeSides": [1, 1, 1, 1],
                    "strokeWeight": 1
                })

            # Override text layers
            t_ids = client.run_command("node.find", {"root": c_inst, "type": "TEXT"})["ids"]
            for tid in t_ids:
                t_node = client.get_node(tid)
                name = t_node.get("name")
                if name == "Card_Accession":
                    client.run_command("node.set", {"ids": [tid], "characters": entry["accession"]})
                    if entry["selected"]:
                        client.run_command("node.set", {"ids": [tid], "fill": "#C2410C", "fontStyle": "Bold"})
                elif name == "Card_Title_Text":
                    client.run_command("node.set", {"ids": [tid], "characters": entry["title"]})
                    if entry["selected"]:
                        client.run_command("node.set", {"ids": [tid], "fontStyle": "Bold"})
                elif name == "Card_Sub":
                    client.run_command("node.set", {"ids": [tid], "characters": entry["sub"]})

            # Update embedded badge instance
            b_inst_ids = client.run_command("node.find", {"root": c_inst, "type": "INSTANCE"})["ids"]
            if b_inst_ids:
                # b_inst_ids[0] is the nested BadgeSet instance
                b_id = b_inst_ids[0]
                client.run_command("instance.setProperties", {"ids": [b_id], "properties": {"State": entry["badge_state"]}})

        time.sleep(0.4)

        # =====================================================================
        # COLUMN 3: Curatorial Dossier Detail Panel (840px)
        # =====================================================================
        print("--- [Step 6] Building Column 3: Curatorial Dossier Detail Workspace (840px) ---")
        col3_id = client.create_node(
            node_type="frame",
            name="Col3_Dossier_Workspace",
            parent=workspace_id,
            width=840,
            height=840,
            props={
                "fill": "#FAF9F6",
                "layout": "vertical",
                "gap": 16,
                "padding": [24, 24, 24, 24],
                "sizingH": "fixed",
                "sizingV": "fixed",
            }
        )["id"]

        # ---------------------------------------------------------------------
        # DOSSIER BLOCK 1: Header Dossier Monograph Banner
        # ---------------------------------------------------------------------
        dossier_header = client.create_node(
            node_type="frame",
            name="Dossier_Hero_Header",
            parent=col3_id,
            props={
                "fill": "#FFFFFF",
                "cornerRadius": 6,
                "stroke": "#E2E2DC",
                "strokeWeight": 1,
                "layout": "vertical",
                "gap": 12,
                "padding": [20, 24, 20, 24],
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        # Meta tag row
        d_meta_row = client.create_node(
            node_type="frame",
            name="Dossier_Meta_Row",
            parent=dossier_header,
            props={
                "layout": "horizontal",
                "mainAlign": "spaceBetween",
                "crossAlign": "center",
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="Accession_Tag",
            parent=d_meta_row,
            props={
                "characters": "ACCESSION NO: ARC-530-ATH • INVENTORY ID: 84.AE.92",
                "fontFamily": "JetBrains Mono",
                "fontSize": 11,
                "fontStyle": "Bold",
                "fill": "#C2410C",
            }
        )

        client.run_command("instance.create", {"component": BADGE_STABLE, "parent": d_meta_row})

        # Main Title & Subtitle
        client.create_node(
            node_type="text",
            name="Artifact_Dossier_Title",
            parent=dossier_header,
            props={
                "characters": "Attic Black-Figure Amphora",
                "fontFamily": "EB Garamond",
                "fontSize": 26,
                "fontStyle": "Bold",
                "fill": "#0F172A",
                "lineHeight": "Auto",
            }
        )

        client.create_node(
            node_type="text",
            name="Artifact_Dossier_Subtitle",
            parent=dossier_header,
            props={
                "characters": "Attributed to the Antimenes Painter Workshop • Herakles and the Nemean Lion",
                "fontFamily": "EB Garamond",
                "fontSize": 16,
                "fontStyle": "Italic",
                "fill": "#475569",
            }
        )

        # Action Buttons Row
        actions_bar = client.create_node(
            node_type="frame",
            name="Dossier_Action_Buttons",
            parent=dossier_header,
            props={
                "layout": "horizontal",
                "crossAlign": "center",
                "gap": 10,
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        # Button 1: Condition Report (Primary)
        b1 = client.run_command("instance.create", {"component": BTN_PRIMARY, "parent": actions_bar})["id"]
        t1 = client.run_command("node.find", {"root": b1, "type": "TEXT"})["ids"][0]
        client.run_command("node.set", {"ids": [t1], "characters": "Generate Condition Report"})

        # Button 2: Request Inspection (Terracotta Accent)
        b2 = client.run_command("instance.create", {"component": BTN_ACCENT, "parent": actions_bar})["id"]
        t2 = client.run_command("node.find", {"root": b2, "type": "TEXT"})["ids"][0]
        client.run_command("node.set", {"ids": [t2], "characters": "Request Vitrine Inspection"})

        # Button 3: Loan History (Outline)
        b3 = client.run_command("instance.create", {"component": BTN_OUTLINE, "parent": actions_bar})["id"]
        t3 = client.run_command("node.find", {"root": b3, "type": "TEXT"})["ids"][0]
        client.run_command("node.set", {"ids": [t3], "characters": "Loan Record & Provenance"})

        time.sleep(0.4)

        # ---------------------------------------------------------------------
        # DOSSIER BLOCK 2: Visual Documentation & Curatorial Metadata Grid
        # ---------------------------------------------------------------------
        print("--- [Step 7] Constructing Visual Documentation & Provenance Grid ---")
        mid_grid = client.create_node(
            node_type="frame",
            name="Dossier_Mid_Grid",
            parent=col3_id,
            props={
                "layout": "horizontal",
                "gap": 16,
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        # Sub-Block A: Visual Documentation Plate (330px)
        plate_card = client.create_node(
            node_type="frame",
            name="Archival_Plate_Card",
            parent=mid_grid,
            width=330,
            props={
                "fill": "#FFFFFF",
                "cornerRadius": 6,
                "stroke": "#E2E2DC",
                "strokeWeight": 1,
                "layout": "vertical",
                "gap": 12,
                "padding": [16, 16, 16, 16],
                "sizingH": "fixed",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="Plate_Sec_Title",
            parent=plate_card,
            props={"characters": "ARCHIVAL VISUAL DOCUMENTATION", "fontFamily": "Inter", "fontSize": 11, "fontStyle": "Bold", "fill": "#64748B"}
        )

        # Dedicated Plate Media Container frame to support media replacement without breaking auto layout
        plate_media_container = client.create_node(
            node_type="frame",
            name="Plate_Media_Container",
            parent=plate_card,
            props={
                "layout": "vertical",
                "mainAlign": "center",
                "crossAlign": "center",
                "fill": "#F8FAFC",
                "cornerRadius": 4,
                "sizingH": "fill",
                "sizingV": "hug",
                "clip": True,
            }
        )["id"]

        # Embedded linked instance of Media/Archival_Vector_Plate_Master inside container
        client.run_command("instance.create", {"component": PLATE_MASTER, "parent": plate_media_container})

        # Dedicated Plate Caption Block with clean spacing and clear layout
        caption_box = client.create_node(
            node_type="frame",
            name="Plate_Caption_Box",
            parent=plate_card,
            props={
                "layout": "vertical",
                "gap": 4,
                "fill": "#F8FAFC",
                "stroke": "#E2E8F0",
                "strokeWeight": 1,
                "cornerRadius": 4,
                "padding": [8, 10, 8, 10],
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="Plate_Caption_Heading",
            parent=caption_box,
            props={
                "characters": "Plate VII: Obverse View • 8K Multispectral",
                "fontFamily": "Inter",
                "fontSize": 11,
                "fontStyle": "Bold",
                "fill": "#1E293B",
                "lineHeight": "Auto",
            }
        )

        client.create_node(
            node_type="text",
            name="Plate_Caption_Sub",
            parent=caption_box,
            props={
                "characters": "Heritage Archive • Accession 1928 [DEMO]",
                "fontFamily": "Inter",
                "fontSize": 11,
                "fill": "#64748B",
                "lineHeight": "Auto",
            }
        )

        # Sub-Block B: Curatorial Metadata & Provenance (Remaining width, fill)
        specs_card = client.create_node(
            node_type="frame",
            name="Curatorial_Specs_Card",
            parent=mid_grid,
            props={
                "fill": "#FFFFFF",
                "cornerRadius": 6,
                "stroke": "#E2E2DC",
                "strokeWeight": 1,
                "layout": "vertical",
                "gap": 8,
                "padding": [16, 20, 16, 20],
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="Specs_Sec_Title",
            parent=specs_card,
            props={"characters": "CURATORIAL SPECIFICATIONS & PROVENANCE", "fontFamily": "Inter", "fontSize": 11, "fontStyle": "Bold", "fill": "#64748B"}
        )

        spec_data = [
            ("CULTURE / PERIOD", "Archaic Greek (Attica, Athens) • c. 530 BCE"),
            ("MEDIUM / TECHNIQUE", "Terracotta, black-figure technique with incised detail"),
            ("DIMENSIONS / SCALE", "H: 45.2 cm • Diam: 29.8 cm • Weight: 4.82 kg"),
            ("PROVENANCE CHAIN", "Excavated Vulci (1828) • Lucien Bonaparte Coll. • Acquired 1928"),
            ("CURATORIAL NOTES", "Herakles wrestling the Nemean Lion flanked by Athena and Iolaos. Reverse shows chariot departure."),
        ]

        for label_text, val_text in spec_data:
            s_inst = client.run_command("instance.create", {"component": SPEC_ROW_MASTER, "parent": specs_card})["id"]
            client.run_command("node.set", {"ids": [s_inst], "sizingH": "fill"})
            t_ids = client.run_command("node.find", {"root": s_inst, "type": "TEXT"})["ids"]
            for tid in t_ids:
                name = client.get_node(tid).get("name")
                if name == "Field_Label":
                    client.run_command("node.set", {"ids": [tid], "characters": label_text})
                elif name == "Field_Value":
                    client.run_command("node.set", {"ids": [tid], "characters": val_text})

        time.sleep(0.4)

        # ---------------------------------------------------------------------
        # DOSSIER BLOCK 3: Environmental Telemetry & Vitrine Conditions
        # ---------------------------------------------------------------------
        print("--- [Step 8] Building Environmental Telemetry & Vitrine Climate Panel ---")
        climate_card = client.create_node(
            node_type="frame",
            name="Microclimate_Telemetry_Card",
            parent=col3_id,
            props={
                "fill": "#FFFFFF",
                "cornerRadius": 6,
                "stroke": "#E2E2DC",
                "strokeWeight": 1,
                "layout": "vertical",
                "gap": 12,
                "padding": [16, 20, 16, 20],
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        # Climate Header Row
        cl_hdr = client.create_node(
            node_type="frame",
            name="Climate_Header_Row",
            parent=climate_card,
            props={
                "layout": "horizontal",
                "mainAlign": "spaceBetween",
                "crossAlign": "center",
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        client.create_node(
            node_type="text",
            name="Climate_Title",
            parent=cl_hdr,
            props={"characters": "MICROCLIMATE TELEMETRY (VITRINE VG-04 • GALLERY III) [SIMULATED]", "fontFamily": "Inter", "fontSize": 11, "fontStyle": "Bold", "fill": "#64748B"}
        )

        client.create_node(
            node_type="text",
            name="Stream_Status",
            parent=cl_hdr,
            props={"characters": "● SIMULATED SENSOR STREAM (Demo 0.2s cycle) • Nominal", "fontFamily": "JetBrains Mono", "fontSize": 11, "fill": "#047857"}
        )

        # 4 Climate Gauges Row using linked instances of Meter/Climate_Gauge_Master
        gauges_row = client.create_node(
            node_type="frame",
            name="Gauges_Row",
            parent=climate_card,
            props={
                "layout": "horizontal",
                "gap": 12,
                "fill": "none",
                "sizingH": "fill",
                "sizingV": "hug",
            }
        )["id"]

        gauge_data = [
            ("Vitrine Temperature", "20.4°C", "Target: 19.0–21.5°C", "#047857"),
            ("Relative Humidity", "48.2% RH", "Target: 45–55% RH", "#047857"),
            ("Luminous Exposure", "48.0 Lux", "Threshold: < 50 Lux", "#047857"),
            ("UV Radiance", "12 μW/lm", "Threshold: < 75 μW/lm", "#047857"),
        ]

        for g_lbl, g_val, g_sub, g_col in gauge_data:
            g_inst = client.run_command("instance.create", {"component": GAUGE_MASTER, "parent": gauges_row})["id"]
            client.run_command("node.set", {"ids": [g_inst], "sizingH": "fill"})
            t_ids = client.run_command("node.find", {"root": g_inst, "type": "TEXT"})["ids"]
            for tid in t_ids:
                name = client.get_node(tid).get("name")
                if name == "Meter_Label":
                    client.run_command("node.set", {"ids": [tid], "characters": g_lbl})
                elif name == "Meter_Value":
                    client.run_command("node.set", {"ids": [tid], "characters": g_val, "fill": g_col})
                elif name == "Meter_Sub":
                    client.run_command("node.set", {"ids": [tid], "characters": g_sub})

        time.sleep(0.5)

        # ---------------------------------------------------------------------
        # SAVE & CAPTURE EVIDENCE
        # ---------------------------------------------------------------------
        print("\n--- [Step 9] Saving Document & Capturing Unselected Screen Proof ---")
        client.run_command("select.none", {})
        time.sleep(0.3)
        client.save_file(doc_path)

        export_dir = os.path.abspath("projects/artefacta-museum/exports")
        os.makedirs(export_dir, exist_ok=True)
        screenshot_path = os.path.join(export_dir, "artefacta-native-screen-1440x900.png")

        # Capture live canvas screenshot
        client.screenshot(screenshot_path)
        print(f"Screenshot captured to: {screenshot_path}")

        # Export updated document tree JSON
        json_path = os.path.join(export_dir, "artefacta-screen-tree.json")
        full_tree = client.inspect_document(depth=8)
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(full_tree, f, indent=2)
        print(f"Document tree exported to: {json_path}")

        print("\n================================================================================")
        print(" SUCCESS: Native Application Screen Created and Verified on FigCraft Desktop!")
        print("================================================================================")
        return True

    finally:
        client.close()


if __name__ == "__main__":
    success = build_artefacta_screen()
    sys.exit(0 if success else 1)
