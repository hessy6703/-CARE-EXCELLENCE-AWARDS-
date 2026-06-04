<?php
/**
 * CEAMS - Core Router Class
 * Handles URL routing and controller dispatching
 */

namespace Core;

class Router
{
    private $routes = [];
    private $baseController = 'App\\Controllers\\HomeController';
    private $currentMethod = 'index';
    private $currentController = null;
    private $currentParams = [];

    /**
     * Register GET route
     */
    public function get($route, $controller, $method = 'index')
    {
        $this->routes['GET'][$route] = [
            'controller' => $controller,
            'method' => $method
        ];
        return $this;
    }

    /**
     * Register POST route
     */
    public function post($route, $controller, $method = 'store')
    {
        $this->routes['POST'][$route] = [
            'controller' => $controller,
            'method' => $method
        ];
        return $this;
    }

    /**
     * Register PUT route
     */
    public function put($route, $controller, $method = 'update')
    {
        $this->routes['PUT'][$route] = [
            'controller' => $controller,
            'method' => $method
        ];
        return $this;
    }

    /**
     * Register DELETE route
     */
    public function delete($route, $controller, $method = 'destroy')
    {
        $this->routes['DELETE'][$route] = [
            'controller' => $controller,
            'method' => $method
        ];
        return $this;
    }

    /**
     * Dispatch request
     */
    public function dispatch($url)
    {
        $url = rtrim($url, '/');
        $method = Request::method();

        // Check exact matches first
        if (isset($this->routes[$method][$url])) {
            $this->route($this->routes[$method][$url]);
            return;
        }

        // Check parametric routes
        foreach ($this->routes[$method] as $route => $config) {
            if ($this->matchRoute($route, $url)) {
                $this->route($config);
                return;
            }
        }

        // 404 Not Found
        http_response_code(404);
        echo "404 - Page Not Found";
        exit;
    }

    /**
     * Match route with parameters
     */
    private function matchRoute($route, $url)
    {
        $pattern = preg_replace('/:([a-zA-Z_][a-zA-Z0-9_]*)/', '([a-zA-Z0-9_-]+)', $route);
        $pattern = '#^' . $pattern . '$#';

        if (preg_match($pattern, $url, $matches)) {
            array_shift($matches);
            $this->currentParams = $matches;
            return true;
        }
        return false;
    }

    /**
     * Execute route
     */
    private function route($config)
    {
        $controllerName = $config['controller'];
        $methodName = $config['method'];

        $controllerClass = 'App\\Controllers\\' . $controllerName;

        if (!class_exists($controllerClass)) {
            die("Controller $controllerClass not found");
        }

        $controller = new $controllerClass();

        if (!method_exists($controller, $methodName)) {
            die("Method $methodName not found in $controllerClass");
        }

        if (count($this->currentParams) > 0) {
            call_user_func_array([$controller, $methodName], $this->currentParams);
        } else {
            $controller->$methodName();
        }
    }
}
