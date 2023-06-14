import json
import boto3
import datetime

translate = boto3.client(service_name='translate')

dynamodb_translate_history_tbl = boto3.resource('dynamodb').Table('translate-history')

def lambda_handler(event, context):

    input_text = event['queryStringParameters']['input_text']

    try:
        response = translate.translate_text(
            Text=input_text,
            SourceLanguageCode="ja",
            TargetLanguageCode="en"
        )

    except Exception as e:
        logging.error(e.response['Error']['Message'])
        raise Exception("[ErrorMessage]: " + str(e))

    output_text = response.get('TranslatedText')

    try:
        dynamodb_translate_history_tbl.put_item(
          Item = {
            "timestamp": datetime.datetime.now().strftime("%Y%m%d%H%M%S"),
            "input_text": input_text,
            "output_text": output_text
          }
        )
    except Exception as e:
        logging.error(e.response['Error']['Message'])
        raise Exception("[ErrorMessage]: " + str(e))

    return {
        'statusCode': 200,
        'body': json.dumps({
            'output_text': output_text
        }),
        'isBase64Encoded': False,
        'headers': {}
    }