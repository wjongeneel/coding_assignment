import xhtml2pdf import pisa
import jinja2 

def generate_html_content(transactions: list) -> str:
    """
    Generates html_content that will be used for generating a pdf report for all transactions that did not pass validation 

    Parameters
    ----------
    transactions: list 
        List of dictionaries containing the transactions that failed validation, should contain reference and description fields 
    
    Returns
    -------
    html_content: str 
        The html content that can be used to generate a pdf report 
    """
    html_template = """
    <!DOCTYPE html>
    <html>
    <style>
        table, th, td {
        text-align: left;
        }
    </style>
    <body>
        <h1>Report: Failed transactions</h1>
        <p>Below you will find a report on transactions that did not pass the validation steps</p>
        <table>
            <tr>
                <th>reference</th>
                <th>description</th>
            </tr>
            {% for transaction in transactions %}
            <tr>
                <td>{{ transaction['reference'] }}</td>
                <td>{{ transaction['description'] }}</td>
            </tr>
            {% endfor %}
        </table>
    </body>
    </html>
    """
    environment = jinja2.Environment() 
    template = environment.from_string(html_template)
    return template.render(transactions=transactions)

def convert_html_to_pdf(html_content: str, pdf_path: str) -> None:
    """
    Converts the provided html_content to a pdf locally stored on the provided pdf_path

    Parameters
    ----------
    html_content: str 
        The html_content to be used to create the pdf 
    pdf_path: str
        The local path to store the generated pdf file to 
    """
    with open(pdf_path, "wb") as pdf_file: 
        pisa_status = pisa.CreatePDF(html_content, dest=pdf_file) 