import boto3
import json
import logging
from custom_encoder import CustomEncoder

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodbTableName = 'CarTable'
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(dynamodbTableName)

getMethod = 'GET'
postMethod = 'POST'
patchMethod = 'PATCH'
deleteMethod = 'DELETE'
healthPath = '/health'
carPath = '/car'
carsPath = '/cars'

def carsHandler(event, context):
    logger.info(event)
    httpMethod = event['httpMethod']
    path = event['resource']

    if httpMethod == getMethod and path == healthPath:
        response = buildResponse(200)
    elif httpMethod == getMethod and path == carPath:
        response = getCar(event['queryStringParameters']['carId'])
    elif httpMethod == getMethod and path == carsPath:
        response = getCars()
    elif httpMethod == postMethod and path == carPath:
        requestBody = json.loads(event['body'])
        response = saveCar(requestBody)
    elif httpMethod == patchMethod and path == carPath:
        requestBody = json.loads(event['body'])
        response = modifyCar(requestBody['carId'], requestBody['updateKey'], requestBody['updateValue'])
    elif httpMethod == deleteMethod and path == carPath:
        requestBody = json.loads(event['body'])
        response = deleteCar(requestBody['carId'])
    else:
        response = buildResponse(404, 'Hey, you reached the carsHandler but nothing has been found. ' + 'stage: ' + event['requestContext']['stage'] + '. httpMethod: ' + httpMethod + '. path: ' + path
                                  + 'resource: ' + event['resource'] 
                                #  + '. rawQueryString: ' + event['rawQueryString'] + '. queryStringParameters: ' + str(event['queryStringParameters']) + '. body: ' + event['body']
                                  + '.')

    return response

def buildResponse(statusCode, body=None):
    response = {
        'statusCode': statusCode,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }
    if body is not None:
        response['body'] = json.dumps(body, cls=CustomEncoder)
    return response

def getCar(carId):
    try:
        response = table.get_item(
            Key={
                'carId': carId
            }
        )
        if 'Item' in response:
            return buildResponse(200, response['Item'])
        else:
            return buildResponse(404, {'Message': 'CarId: %s not found' % carId})
    except:
        logger.exception('getCar failed.')

def getCars():
    try:
        response = table.scan()
        result = response['Items']
        
        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            result.extend(response['Items'])
        
        body = {
            'cars': result
        }
        return buildResponse(200, body)
    except:
        logger.exception('getCars failed.')

def saveCar(requestBody):
    try:
        table.put_item(Item=requestBody)
        body = {
            'Operation': 'SAVE',
            'Message': 'SUCCESS',
            'Item': requestBody
        }
        return buildResponse(200, body)
    except:
        logger.exception('saveCar failed.')

def modifyCar(carId, updateKey, updateValue):
    try:
        response = table.update_item(
            Key={
                'carId': carId
            },
            UpdateExpression='set %s = :value' % updateKey,
            ExpressionAttributeValues={
                ':value': updateValue
            },
            ReturnValues='UPDATED_NEW'
        )
        body = {
            'Operation': 'UPDATE',
            'Message': 'SUCCESS',
            'UpdatedAttributes': response
        }
        return buildResponse(200, body)
    except:
        logger.exception('modifyCar failed.')

def deleteCar(carId):
    try:
        response = table.delete_item(
            Key={
                'carId': carId
            },
            ReturnValues='ALL_OLD'
        )
        body = {
            'Operation': 'DELETE',
            'Message': 'SUCCESS',
            'deletedItem': response
        }
        return buildResponse(200, body)
    except:
        logger.exception('deleteCar failed.')
