import xml.etree.ElementTree as ET
import json
import os
import argparse
from datetime import datetime

def parse_xml_report(xml_file):
    """
    Parse SQLMap XML report and extract relevant information
    """
    tree = ET.parse(xml_file)
    root = tree.getroot()
    
    report = {
        "target": root.find("target").text,
        "date": root.find("date").text,
        "vulnerabilities": []
    }
    
    for vuln in root.findall("vulnerability"):
        vuln_info = {
            "parameter": vuln.find("parameter").text,
            "type": vuln.find("type").text,
            "payload": vuln.find("payload").text,
            "title": vuln.find("title").text,
            "description": vuln.find("description").text
        }
        report["vulnerabilities"].append(vuln_info)
    
    return report

def generate_html_report(xml_file, output_file):
    """
    Generate HTML report from XML data
    """
    report = parse_xml_report(xml_file)
    
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>SQL Injection Test Report</title>
        <style>
            body {{ font-family: Arial, sans-serif; }}
            .header {{ background-color: #2c3e50; color: white; padding: 20px; }}
            .vulnerability {{ margin: 20px 0; padding: 15px; border: 1px solid #ddd; }}
            .vuln-title {{ color: #e74c3c; font-weight: bold; }}
            .code {{ background-color: #f8f9fa; padding: 10px; border-radius: 4px; }}
        </style>
    </head>
    <body>
        <div class="header">
            <h1>SQL Injection Test Report</h1>
            <p>Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</p>
        </div>
        
        <h2>Target: {report['target']}</h2>
        <p>Test Date: {report['date']}</p>
        
        <div class="vulnerabilities">
            <h3>Detected Vulnerabilities</h3>
            {"".join([f"""
                <div class="vulnerability">
                    <h4 class="vuln-title">{vuln['title']}</h4>
                    <p><strong>Parameter:</strong> {vuln['parameter']}</p>
                    <p><strong>Type:</strong> {vuln['type']}</p>
                    <div class="code">
                        <pre>{vuln['payload']}</pre>
                    </div>
                    <p><strong>Description:</strong> {vuln['description']}</p>
                </div>
            """ for vuln in report['vulnerabilities']])}
        </div>
    </body>
    </html>
    """
    
    with open(output_file, "w") as f:
        f.write(html_content)

def main():
    parser = argparse.ArgumentParser(description="SQL Injection Report Generator")
    parser.add_argument("-i", "--input", required=True, help="Input XML file")
    parser.add_argument("-o", "--output", required=True, help="Output HTML file")
    
    args = parser.parse_args()
    
    try:
        generate_html_report(args.input, args.output)
        print(f"[+] Report generated successfully: {args.output}")
    except Exception as e:
        print(f"[!] Error generating report: {str(e)}")

if __name__ == "__main__":
    main()
