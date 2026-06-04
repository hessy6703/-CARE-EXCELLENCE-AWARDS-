<?php
/**
 * CEAMS - Core Request Class
 * Handles HTTP requests and data validation
 */

namespace Core;

class Request
{
    /**
     * Get request method (GET, POST, PUT, DELETE)
     */
    public static function method()
    {
        return $_SERVER['REQUEST_METHOD'];
    }

    /**
     * Check if request is GET
     */
    public static function isGet()
    {
        return self::method() === 'GET';
    }

    /**
     * Check if request is POST
     */
    public static function isPost()
    {
        return self::method() === 'POST';
    }

    /**
     * Get value from GET
     */
    public static function get($key = null, $default = null)
    {
        if ($key === null) {
            return $_GET;
        }
        return $_GET[$key] ?? $default;
    }

    /**
     * Get value from POST
     */
    public static function post($key = null, $default = null)
    {
        if ($key === null) {
            return $_POST;
        }
        return $_POST[$key] ?? $default;
    }

    /**
     * Get value from REQUEST
     */
    public static function input($key = null, $default = null)
    {
        if ($key === null) {
            return array_merge($_GET, $_POST);
        }
        return $_GET[$key] ?? $_POST[$key] ?? $default;
    }

    /**
     * Check if key exists in POST
     */
    public static function has($key)
    {
        return isset($_POST[$key]) || isset($_GET[$key]);
    }

    /**
     * Get uploaded file
     */
    public static function file($key = null)
    {
        if ($key === null) {
            return $_FILES;
        }
        return $_FILES[$key] ?? null;
    }

    /**
     * Get URI
     */
    public static function uri()
    {
        return parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    }

    /**
     * Get base URL
     */
    public static function baseUrl()
    {
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || $_SERVER['SERVER_PORT'] == 443) ? 'https://' : 'http://';
        return $protocol . $_SERVER['HTTP_HOST'] . dirname($_SERVER['SCRIPT_NAME']);
    }

    /**
     * Get IP address
     */
    public static function ip()
    {
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ip = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
        } else {
            $ip = $_SERVER['REMOTE_ADDR'];
        }
        return $ip;
    }

    /**
     * Get user agent
     */
    public static function userAgent()
    {
        return $_SERVER['HTTP_USER_AGENT'] ?? '';
    }

    /**
     * Sanitize input
     */
    public static function sanitize($data)
    {
        if (is_array($data)) {
            return array_map([self::class, 'sanitize'], $data);
        }
        return htmlspecialchars(trim($data), ENT_QUOTES, 'UTF-8');
    }

    /**
     * Validate input
     */
    public static function validate($data, $rules)
    {
        $errors = [];

        foreach ($rules as $field => $rule) {
            $value = $data[$field] ?? '';

            if (strpos($rule, 'required') !== false) {
                if (empty($value)) {
                    $errors[$field] = "$field is required";
                    continue;
                }
            }

            if (strpos($rule, 'email') !== false && !empty($value)) {
                if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $errors[$field] = "$field must be a valid email";
                }
            }

            if (strpos($rule, 'min:') !== false && !empty($value)) {
                preg_match('/min:(\d+)/', $rule, $matches);
                $min = $matches[1];
                if (strlen($value) < $min) {
                    $errors[$field] = "$field must be at least $min characters";
                }
            }

            if (strpos($rule, 'max:') !== false && !empty($value)) {
                preg_match('/max:(\d+)/', $rule, $matches);
                $max = $matches[1];
                if (strlen($value) > $max) {
                    $errors[$field] = "$field must not exceed $max characters";
                }
            }
        }

        return $errors;
    }
}
