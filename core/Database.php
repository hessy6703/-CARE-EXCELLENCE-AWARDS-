<?php
/**
 * CEAMS - Core Database Class
 * Handles all database connections and operations
 */

namespace Core;

use PDO;
use PDOException;

class Database
{
    private $connection;
    private $statement;
    private $error;

    public function __construct($config)
    {
        $dsn = 'mysql:host=' . $config['host'] . ';dbname=' . $config['database'] . ';charset=utf8mb4';

        $options = [
            PDO::ATTR_PERSISTENT => false,
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];

        try {
            $this->connection = new PDO($dsn, $config['user'], $config['password'], $options);
        } catch (PDOException $e) {
            $this->error = $e->getMessage();
            die('Database Connection Error: ' . $this->error);
        }
    }

    /**
     * Prepare statement
     */
    public function query($sql)
    {
        $this->statement = $this->connection->prepare($sql);
        return $this;
    }

    /**
     * Bind values
     */
    public function bind($param, $value, $type = PDO::PARAM_STR)
    {
        $this->statement->bindValue($param, $value, $type);
        return $this;
    }

    /**
     * Execute prepared statement
     */
    public function execute()
    {
        return $this->statement->execute();
    }

    /**
     * Get result set as array
     */
    public function resultSet()
    {
        $this->execute();
        return $this->statement->fetchAll();
    }

    /**
     * Get single record
     */
    public function single()
    {
        $this->execute();
        return $this->statement->fetch();
    }

    /**
     * Get row count
     */
    public function rowCount()
    {
        return $this->statement->rowCount();
    }

    /**
     * Get last inserted ID
     */
    public function lastInsertId()
    {
        return $this->connection->lastInsertId();
    }

    /**
     * Begin transaction
     */
    public function beginTransaction()
    {
        return $this->connection->beginTransaction();
    }

    /**
     * Commit transaction
     */
    public function commit()
    {
        return $this->connection->commit();
    }

    /**
     * Rollback transaction
     */
    public function rollBack()
    {
        return $this->connection->rollBack();
    }
}
