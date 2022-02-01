<?php 

// Laravel and GuzzleHTTP\Client

function verifyReceiptWithApple() {
        $input = file_get_contents('php://input');
        $request = json_decode($input);

        $d = $request->receipt;
        $secret = 'your_app_purchase_secret';

        //$url = 'https://sandbox.itunes.apple.com/verifyReceipt';
        $url = 'https://buy.itunes.apple.com/verifyReceipt';

        // Replace with curl if you are not using Laravel
        $client = new Client([
            'headers' => [ 'Content-Type' => 'application/json' ]
        ]);
        
        $response = $client->post($url,
            ['body' => json_encode(
                [
                    'receipt-data' => $d,
                    'password' => $secret,
                    'exclude-old-transactions' => false
                ]
            )]
        );

        $json = json_decode($response->getBody()->getContents());
        if ($json->status == 0) {

            $email = "";

            // Get original transaction id
            $receipts = $json->receipt->in_app;
            if (!empty($receipts) && count($receipts) > 0) {
                $first_receipt = $receipts[0];
                if ($first_receipt->in_app_ownership_type == "PURCHASED") {
                    $original_transaction_id = $first_receipt->original_transaction_id;

                    // Create email address with transaction id 
                    // Create new user if not exists
                    $email = $original_transaction_id.'@domain.com';
                    $have_user = "check_with_your_database";
                    if (!$have_user) {
                        // New purchase -> user not found
                    } else {
                        // Restore purchase -> user found 
                        
                    }
                }
            }

            return response()->json(["status" => 1, "message" => "Receipt is verified"]);
        } else {
            return response()->json(["status" => 0, "message" => "Invalid receipt"]);
        }
    }