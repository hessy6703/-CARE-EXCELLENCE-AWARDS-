<?php
/**
 * CEAMS - Core Response Class
 * Handles HTTP responses
 */

namespace Core;

class Response
{
    /**
     * Set response header
     */
    public static function header($header)
    {
        header($header);
    }

    /**
     * Set response status code
     */
    public static function status($code)
    {
        http_response_code($code);
    }

    /**
     * Return JSON response
     */
    public static function json($data, $statusCode = 200)
    {
        self::header('Content-Type: application/json');
        self::status($statusCode);
        echo json_encode($data);
        exit;
    }

    /**
     * Redirect to URL
     */
    public static function redirect($url)
    {
        self::header('Location: ' . $url);
        exit;
    }

    /**
     * Set flash message
     */
    public static function flash($message, $type = 'info')
    {
        $_SESSION['flash'] = [
            'message' => $message,
            'type' => $type
        ];
    }

    /**
     * Get and clear flash message
     */
    public static function getFlash()
    {
        if (isset($_SESSION['flash'])) {
            $flash = $_SESSION['flash'];
            unset($_SESSION['flash']);
            return $flash;
        }
        return null;
    }
}
